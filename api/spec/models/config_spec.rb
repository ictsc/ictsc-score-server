require_relative '../spec_helper.rb'

describe Config do
  describe '#value_type' do
    it 'can set :boolean' do
      expect { build(:config, :boolean) }.not_to raise_error
    end

    it 'can set :integer' do
      expect { build(:config, :integer) }.to_not raise_error
    end

    it 'can set :string' do
      expect { build(:config, :string) }.to_not raise_error
    end

    it 'can set :date' do
      expect { build(:config, :date) }.to_not raise_error
    end

    it 'cannot set not registered value_type' do
      expect { Config.new(key: 'a', value: '1', value_type: :other_value) }.to raise_error(ArgumentError)
    end
  end

  describe '#valid?' do
    describe '#validate_castable' do
      it 'allow castable value' do
        expect(build(:config, value: '1000', value_type: :integer)).to be_valid
        expect(build(:config, value: true, value_type: :boolean)).to be_valid
        expect(build(:config, value: 0, value_type: :boolean)).to be_valid
      end

      it 'reject not castable value' do
        expect(build(:config, value: 'hello', value_type: :date)).to_not be_valid
      end
    end

    describe '#reject_update_value_type' do
      let(:config) { build(:config, key: 'key', value: '0', value_type: :boolean) }

      it 'reject update :value_type' do
        expect(config.save).to eq(true)
        expect(config.update(value_type: :integer)).to eq false
      end
    end
  end

  describe 'class method' do
    describe '#get' do
      let(:value) { 99 }
      let(:config) { create(:config, :integer, value: value) }

      it 'record is exist' do
        expect(Config.get(config.key)).to eq value
      end

      it 'record is not exist' do
        expect(Config.get('aaaaaaa')).to eq nil
      end
    end

    describe '#get!' do
      let(:value) { 99 }
      let(:config) { create(:config, :integer, value: value) }

      it 'record is exist' do
        expect(Config.get!(config.key)).to eq value
      end

      it 'record is not exist' do
        expect{ Config.get!('aaaaaaa') }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    describe '#set' do
      let(:value) { 10 }
      let(:new_value) { 99 }

      context 'record is exist' do
        let(:config) { create(:config, :integer, value: value) }

        it 'castable value' do
          expect(Config.set(config.key, new_value)).to eq true
          expect(Config.find_by_key(config.key).value).to eq new_value.to_s
        end

        it 'not castable value' do
          expect(Config.set(config.key, "zZZ")).to eq false
        end
      end

      it 'record is not exist' do
        expect(Config.set('zzzz', 10)).to eq nil
      end
    end

    describe '#set!' do
      let(:value) { 10 }
      let(:new_value) { 99 }

      context 'record is exist' do
        let(:config) { create(:config, :integer, value: value) }

        it 'castable value' do
          expect(Config.set!(config.key, new_value)).to eq true
          expect(Config.find_by_key(config.key).value).to eq new_value.to_s
        end

        it 'not castable value' do
          expect { Config.set!(config.key, "zZZ") }.to raise_error ActiveRecord::RecordInvalid
        end
      end

      it 'record is not exist' do
        expect { Config.set!('zzzz', 10) }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    describe '#cast' do
      let(:config) { build(:config, ) }

      context 'boolean' do
        it 'successe' do
          expect(Config.cast(build(:config, :boolean, value: true))).to eq true
          expect(Config.cast(build(:config, :boolean, value: false))).to eq false

          expect(Config.cast(build(:config, :boolean, value: 1))).to eq true
          expect(Config.cast(build(:config, :boolean, value: 0))).to eq false

          expect(Config.cast(build(:config, :boolean, value: '1'))).to eq true
          expect(Config.cast(build(:config, :boolean, value: '0'))).to eq false
        end

        it 'fail' do
          expect(Config.cast(build(:config, :boolean, value: nil))).to eq nil

          expect(Config.cast(build(:config, :boolean, value: 10))).to eq nil
          expect(Config.cast(build(:config, :boolean, value: -1))).to eq nil

          expect(Config.cast(build(:config, :boolean, value: '10'))).to eq nil
          expect(Config.cast(build(:config, :boolean, value: '-1'))).to eq nil
        end
      end

      context 'integer' do
        it 'success' do
          expect(Config.cast(build(:config, :integer, value: 0))).to eq 0
          expect(Config.cast(build(:config, :integer, value: 1))).to eq 1
          expect(Config.cast(build(:config, :integer, value: '0'))).to eq 0
          expect(Config.cast(build(:config, :integer, value: '1'))).to eq 1
          expect(Config.cast(build(:config, :integer, value: '10'))).to eq 10
          expect(Config.cast(build(:config, :integer, value: '-1'))).to eq -1
          expect(Config.cast(build(:config, :integer, value: '0xa'))).to eq 10
          expect(Config.cast(build(:config, :integer, value: '033'))).to eq 27
        end

        it 'fail' do
          expect(Config.cast(build(:config, :integer, value: ''))).to eq nil
          expect(Config.cast(build(:config, :integer, value: '0xg'))).to eq nil
          expect(Config.cast(build(:config, :integer, value: '09'))).to eq nil
          expect(Config.cast(build(:config, :integer, value: 'a'))).to eq nil
        end
      end

      context 'string' do
        it 'success' do
          expect(Config.cast(build(:config, :string, value: ''))).to eq ''
          expect(Config.cast(build(:config, :string, value: 'a'))).to eq 'a'
          expect(Config.cast(build(:config, :string, value: 'aa'))).to eq 'aa'
        end
      end

      context 'date' do
        it 'success' do
          expect(Config.cast(build(:config, :date, value: '10:00'))).to eq DateTime.parse('10:00')
          expect(Config.cast(build(:config, :date, value: '2019-01-01'))).to eq DateTime.parse('2019-01-01')
        end

        it 'fail' do
          expect(Config.cast(build(:config, :date, value: ''))).to eq nil
          expect(Config.cast(build(:config, :date, value: '0'))).to eq nil
        end
      end
    end

    describe '#cast!' do
      it 'when failed raise Config::CastFailed exception' do
        expect { Config.cast!(build(:config, :integer, value: '')) }.to raise_error(Config::CastFailed)
      end
    end

    describe '#castable?' do
      it 'when succeeded return true' do
        expect(Config.castable?(build(:config, :integer, value: 0))).to eq true
      end

      it 'when failed return false' do
        expect(Config.castable?(build(:config, :integer, value: ''))).to eq false
      end
    end
  end

  describe 'Interfaces' do
    describe '#required_keys' do
      let(:required_keys) do
        %i(competition_time_day1_start_at competition_time_day1_end_at
           competition_time_day2_start_at competition_time_day2_end_at
           competition_stop problem_open_all_at grading_delay_sec
           scoreboard_hide_at scoreboard_top
           scoreboard_display_top_team scoreboard_display_top_score
           scoreboard_display_above_team scoreboard_display_above_score)
      end

      subject { Config.required_keys }

      it { is_expected.to contain_exactly *required_keys }
    end

    describe '#record_accessor' do
      let(:key) { :foobar }
      let(:initial_value) { 10 }
      let(:new_value) { 99 }

      before do
        Config.record_accessor(key)
        Config.create(key: key, value: initial_value, value_type: :integer)
      end

      it { expect { Config.record_accessor(key) }.to change { Config.required_keys.size }.by(1) }

      it 'can get value' do
        expect(Config.foobar).to eq initial_value
      end

      it 'can set value' do
        expect { Config.foobar = new_value }.to change { Config.find_by_key(key).value }.from(initial_value.to_s).to(new_value.to_s)
        expect(Config.foobar).to eq new_value
      end
    end


    it '#competition_time' do
      expect(Config.competition_time.count).to eq 2
      expect(Config.competition_time).to eq [
        { start_at: Config.competition_time_day1_start_at, end_at: Config.competition_time_day1_end_at  },
        { start_at: Config.competition_time_day2_start_at, end_at: Config.competition_time_day2_end_at  }
      ]
    end

    it '#competition_start_at' do
      expect(Config.competition_start_at).to_not eq nil
      expect(Config.competition_start_at).to eq Config.competition_time_day1_start_at
    end

    it 'competition_end_at' do
      expect(Config.competition_end_at).to_not eq nil
      expect(Config.competition_end_at).to eq Config.competition_time_day2_end_at
    end

    it '#scoreboard' do
      expect(Config.scoreboard.keys).to contain_exactly(:hide_at, :top, :display)
      expect(Config.scoreboard[:hide_at]).to eq Config.scoreboard_hide_at
      expect(Config.scoreboard[:top]).to eq Config.scoreboard_top
      expect(Config.scoreboard[:display]).to eq Config.scoreboard_display
    end

    it '#scoreboard_display' do
      expect(Config.scoreboard_display).to match({
        all: {
          team: true,
          score: true
        },
        top: {
          team: Config.scoreboard_display_top_team,
          score: Config.scoreboard_display_top_score
        },
        above: {
          team: Config.scoreboard_display_above_team,
          score: Config.scoreboard_display_above_score
        }
      })
    end

    it '#to_h' do
      expect(Config.to_h).to match({
        competition_time: Config.competition_time,
        competition_stop: Config.competition_stop,
        problem_open_all_at: Config.problem_open_all_at,
        grading_delay_sec: Config.grading_delay_sec,
        scoreboard: Config.scoreboard
      })
    end

    describe '#in_competition_time?' do
      subject { Config.in_competition_time? }

      it 'before day1 start' do
        allow(DateTime).to receive(:now).and_return(Config.competition_time_day1_start_at - 1.second)
        expect(Config.in_competition_time?).to eq false
      end

      it 'after day1 end' do
        allow(DateTime).to receive(:now).and_return(Config.competition_time_day1_end_at + 1.second)
        expect(Config.in_competition_time?).to eq false
      end

      it 'same as day1 start' do
        allow(DateTime).to receive(:now).and_return(Config.competition_time_day1_start_at)
        expect(Config.in_competition_time?).to eq true
      end

      it 'same as day1 end' do
        allow(DateTime).to receive(:now).and_return(Config.competition_time_day1_end_at)
        expect(Config.in_competition_time?).to eq true
      end

      it 'between day 1' do
        allow(DateTime).to receive(:now).and_return(Config.competition_time_day1_start_at + 1.second)
        expect(Config.in_competition_time?).to eq true
      end

      it 'before day2 start' do
        allow(DateTime).to receive(:now).and_return(Config.competition_time_day2_start_at - 1.second)
        expect(Config.in_competition_time?).to eq false
      end

      it 'after day2 end' do
        allow(DateTime).to receive(:now).and_return(Config.competition_time_day2_end_at + 1.second)
        expect(Config.in_competition_time?).to eq false
      end

      it 'same as day2 start' do
        allow(DateTime).to receive(:now).and_return(Config.competition_time_day2_start_at)
        expect(Config.in_competition_time?).to eq true
      end

      it 'same as day2 end' do
        allow(DateTime).to receive(:now).and_return(Config.competition_time_day2_end_at)
        expect(Config.in_competition_time?).to eq true
      end

      it 'between day 1' do
        allow(DateTime).to receive(:now).and_return(Config.competition_time_day2_start_at + 1.second)
        expect(Config.in_competition_time?).to eq true
      end
    end
  end
end
