import DefaultTheme from 'vitepress/theme'
import { nextTick, onMounted, watch } from 'vue'
import { useRoute } from 'vitepress'
import './custom.css'

export default {
  extends: DefaultTheme,
  setup() {
    const route = useRoute()

    async function renderMermaid() {
      if (typeof window === 'undefined') return

      const mermaid = (await import('mermaid')).default
      mermaid.initialize({
        startOnLoad: false,
        securityLevel: 'strict',
        theme: document.documentElement.classList.contains('dark') ? 'dark' : 'neutral',
      })

      await nextTick()
      await mermaid.run({ querySelector: '.mermaid:not([data-processed="true"])' })
    }

    onMounted(renderMermaid)
    watch(() => route.path, renderMermaid)
  },
}
