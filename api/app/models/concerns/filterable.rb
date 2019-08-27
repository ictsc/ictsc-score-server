# frozen_string_literal: true

# レコード単位、カラム単位のフィルタを行う
# メソッドチェーンでクエリを構築できるようにモデルにincludeして使う
# ここで、定義されているメソッドは軒並みteamを引数に取り、多くの場合teamはcurrent_teamなためデフォルト引数にする
module Filterable
  extend ActiveSupport::Concern

  def readable(team: Context.current_team!)
    readable?(team: team) ? filter_columns(team: team) : nil
  end

  def readable?(team: Context.current_team!)
    self.class.readable_records(team: team).exists?(id: id)
  end

  def filter_columns(team: Context.current_team!)
    self.class.reject_columns(team: team).each {|key| self[key] = nil }
    self
  end

  module ClassMethods
    def readables(team: Context.current_team!)
      readable_records(team: team).filter_columns(team: team)
    end

    def filter_columns(team: Context.current_team!)
      cols = readable_columns(team: team)
      cols.empty? ? none : select(*cols)
    end

    def readable_columns(team: Context.current_team!)
      column_names - reject_columns(team: team)
    end

    # ブラックリスト方式でフィルタする
    # そのteamが閲覧できるレコードを返す
    def reject_columns(team: Context.current_team!)
      # 文字列として比較しないとautoload環境では正しく動作しない
      case self.to_s
      when 'Answer'
        %w[confirming] unless team.staff?
      when 'Category'
        %w[code] unless team.staff?
      when 'Problem'
        %w[code secret_text writer] unless team.staff?
      when 'ProblemBody'
        %w[corrects] if team.player?
      when 'Team'
        %w[password_digest]
      when 'Attachment', 'Config', 'FirstCorrectAnswer', 'Notice', 'ProblemEnvironment', 'ProblemSupplement', 'Issue', 'IssueComment', 'Score'
        # permit all
        %w[]
      else
        raise UnhandledClass, self
      end
        .presence || []
    end

    def readable_records(team: Context.current_team!)
      # 文字列として比較しないとautoload環境では正しく動作しない
      klass = self.to_s

      # 運営は常に全テーブルの全レコード取得可能
      return all if team.staff?

      # 参加者や見学者は常に取得不可
      return none if %w[Config].include?(klass)

      # 参加者や見学者は競技時間外やコンテスト中断時にはお知らせ以外は取得不可能
      return none if !Config.competition? && !%w[Notice].include?(klass)

      # 誰でも取得可能
      # Problem自体は常時見れるがProblemBody(問題文)はそうではない
      return all if %w[Category Problem].include?(klass)

      # 見学者なら一部のテーブルを除き全レコード取得可能
      return all if team.audience? && models(ignore: %w[Attachment Config Notice]).include?(klass)

      case klass
      when 'Answer'
        where(team: team, problem: Problem.opened(team: team))
      when 'Attachment'
        # レコードが取得不可でもtokenがあればデータ本体は取得可能
        where(team: team)
      when 'Score'
        return none if !team.staff? && Config.hide_all_score

        # joins(:answer).merge(Answer.delay_filter).where(answers: { team: team })
        where(answer: Answer.readable_records.delay_filter)
      when 'FirstCorrectAnswer'
        # TODO: update方式だと、遅延の影響で一時的に Problem#solved_countが減る
        #       insert方式にして最新のみ使いようにしたほうがいい
        delay_filter.where(team: team)
      when 'Issue'
        where(team: team, problem: Problem.opened(team: team))
      when 'IssueComment'
        where(issue: Issue.readable_records)
      when 'ProblemBody', 'ProblemSupplement'
        where(problem: Problem.opened(team: team))
      when 'ProblemEnvironment'
        # playerには展開が完了した問題環境しか見せない
        where(team: team, problem: Problem.opened(team: team), status: 'APPLIED')
      when 'Team'
        # 自分以下の権限のチームを取得できる
        where(role: -Float::INFINITY..Team.roles[team.role])
      when 'Notice'
        # プレイヤーと見学者は全体宛か、自チーム向けのみ
        # target_team == nil 全体お知らせ
        where(target_team: [nil, team.id])
      else
        raise UnhandledClass, self
      end
    end
  end
end
