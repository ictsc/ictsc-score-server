<template>
  <div>
    <div v-if="show" v-on:click="close()" class="modal fade show">
      <div v-on:click="clickGuard($event)" class="messagebox modal-dialog" :class="{ 'modal-lg': big }">
        <div class="modal-content">
          <button v-on:click="close()" type="button" class="close">
            <i class="fa fa-close"></i>
          </button>
          <h5 class="messagebox-title"><slot name="title"></slot></h5>
          <div class="messagebox-body">
            <slot name="body"></slot>
          </div>
          <div class="messagebox-footer">
            <slot name="buttons" :close="close">
              <button type="button" class="btn btn-secondary">Close</button>
              <button type="button" class="btn btn-primary">Save changes</button>
            </slot>
          </div>
        </div>
      </div>
    </div>
    <div v-if="show" class="modal-backdrop fade" :class="{ show }"></div>
  </div>
</template>

<style scoped>
.modal {
  overflow-y: auto;
}

.modal.show {
  display: block;
  position: absolute;
}

.messagebox {
  max-width: 700px;
  margin-top: 100px;
}

.messagebox-title {
  text-align: center;
  margin: 1rem 0;
  font-weight: bold;
  font-size: 1.7rem;
}

.messagebox-body {
  margin: 1rem 0;
  text-align: center;
}
.messagebox-body ul,
.messagebox-body ol,
.messagebox-body table {
  text-align: left;
}

.modal-content {
  padding: 4rem;
  position: relative;
}

.messagebox button.close {
  position: absolute;
  top: .5rem;
  right: .5rem;
  padding: .5rem;
}

.messagebox-footer {
  text-align: center;
}
</style>

<script>
export default {
  name: 'message-box',
  props: ['value', 'big'],
  data () {
    return {
      show: true,
    }
  },
  asyncData: {
  },
  computed: {
  },
  watch: {
    value (value) {
      this.show = value;
    },
    show (value) {
      if (this.value !== value) {
        this.$emit('input', value);
      }
    },
  },
  mounted () {
    this.show = this.value;
  },
  destroyed () {
  },
  methods: {
    close () {
      this.show = false;
    },
    clickGuard (e) {
      if (e) {
        e.stopPropagation();
      }
    },
  },
}
</script>
