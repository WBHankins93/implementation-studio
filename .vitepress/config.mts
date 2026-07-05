import { defineConfig } from 'vitepress'

const siteUrl = 'https://wbhankins93.github.io/implementation-studio/'
const siteName = 'Implementation Studio'
const tagline = 'Battle-tested implementation patterns for deploying software in constrained customer environments: air-gapped networks, private clusters, firewall restrictions, and multi-tenant platforms.'
const ogImage = `${siteUrl}og-image.png`
const siteAuthor = 'Ben Hankins'
const publishedDate = '2026-07-01T00:00:00Z'

const seriesNav = {
  text: 'The Series',
  items: [
    { text: 'Solutions Playbook', link: 'https://wbhankins93.github.io/solutions-playbook/' },
    { text: 'AI Engineering Studio', link: 'https://wbhankins93.github.io/ai-engineering-studio/' },
    { text: 'DevOps Studio', link: 'https://wbhankins93.github.io/devops-studio/' },
    { text: 'Implementation Studio', link: 'https://wbhankins93.github.io/implementation-studio/' },
  ],
}

const labs = [
  { text: 'Overview', link: '/labs/' },
  { text: '01 Standard Deployment', link: '/labs/01-standard-deployment/' },
  { text: '02 Air-Gapped Deployment', link: '/labs/02-airgapped-deployment/' },
  { text: '03 Private Network Deployment', link: '/labs/03-private-network-deployment/' },
  { text: '04 Firewall-Restricted Deployment', link: '/labs/04-firewall-restricted-deployment/' },
  { text: '05 POC Sprint', link: '/labs/05-poc-sprint/' },
  { text: '06 Multi-Tenant Deployment', link: '/labs/06-multi-tenant-deployment/' },
  { text: '07 Integration Patterns', link: '/labs/07-integration-patterns/' },
  { text: '08 Handoff and Runbooks', link: '/labs/08-handoff-runbooks/' },
  { text: '09 Troubleshooting Scenarios', link: '/labs/09-troubleshooting-scenarios/' },
]

const modules = [
  { text: 'Overview', link: '/modules/' },
  { text: 'AWS ECR', link: '/modules/aws/ecr/' },
  { text: 'AWS EKS Cluster', link: '/modules/aws/eks-cluster/' },
  { text: 'AWS RDS', link: '/modules/aws/rds/' },
  { text: 'AWS Security Groups', link: '/modules/aws/security-groups/' },
  { text: 'AWS VPC', link: '/modules/aws/vpc/' },
  { text: 'AWS Private VPC', link: '/modules/aws/vpc-private/' },
  { text: 'GCP Artifact Registry', link: '/modules/gcp/artifact-registry/' },
  { text: 'GCP Firewall Rules', link: '/modules/gcp/firewall-rules/' },
  { text: 'GCP GKE Cluster', link: '/modules/gcp/gke-cluster/' },
  { text: 'GCP Private VPC', link: '/modules/gcp/vpc-private/' },
  { text: 'GCP Standard VPC', link: '/modules/gcp/vpc-standard/' },
  { text: 'Kubernetes Argo Workflows', link: '/modules/kubernetes/argo-workflows/' },
  { text: 'Kubernetes Air-Gap Argo', link: '/modules/kubernetes/argo-workflows-airgap/' },
  { text: 'Kubernetes Ingress NGINX', link: '/modules/kubernetes/ingress-nginx/' },
  { text: 'Kubernetes Network Policies', link: '/modules/kubernetes/network-policies/' },
  { text: 'Kubernetes RBAC Patterns', link: '/modules/kubernetes/rbac-patterns/' },
  { text: 'Kubernetes Resource Quotas', link: '/modules/kubernetes/resource-quotas/' },
]

const guides = [
  { text: 'Start Here', link: '/START-HERE' },
  { text: 'Content Index', link: '/CONTENT-INDEX' },
  { text: 'Learning Paths', link: '/LEARNING-PATHS' },
  { text: 'Visual Diagrams', link: '/VISUAL-DIAGRAMS' },
  { text: 'Project Status', link: '/PROJECT-STATUS' },
  { text: 'Documentation Index', link: '/docs/' },
  { text: 'Getting Started', link: '/docs/01-getting-started/getting-started' },
  { text: 'Reference Application', link: '/docs/01-getting-started/reference-application' },
  { text: 'SE Integration', link: '/docs/se-integration' },
]

const multiCloud = [
  { text: 'Provider Comparison', link: '/docs/02-multi-cloud/provider-comparison' },
  { text: 'Feature Parity Matrix', link: '/docs/02-multi-cloud/feature-parity-matrix' },
  { text: 'Migration Guide', link: '/docs/02-multi-cloud/migration-guide' },
  { text: 'Multi-Cloud Considerations', link: '/docs/02-multi-cloud/multi-cloud-considerations' },
]

const operations = [
  { text: 'Cost Management', link: '/docs/05-operations/cost-management' },
  { text: 'Disaster Recovery', link: '/docs/05-operations/disaster-recovery' },
  { text: 'Multi-Region Patterns', link: '/docs/05-operations/multi-region-patterns' },
]

export default defineConfig({
  title: 'Implementation Studio',
  description: 'Implementation guides, labs, modules, and diagrams for constrained customer environments.',
  lang: 'en-US',
  base: '/implementation-studio/',
  cleanUrls: true,
  lastUpdated: true,
  ignoreDeadLinks: [/\/LICENSE$/, /^http:\/\/localhost:/],
  srcExclude: ['**/node_modules/**', '**/.terraform/**', '**/.vitepress/dist/**'],
  sitemap: {
    hostname: siteUrl,
  },
  head: [
    ['meta', { name: 'theme-color', content: '#2563eb' }],
    ['meta', { name: 'author', content: siteAuthor }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:site_name', content: siteName }],
    ['meta', { property: 'og:title', content: siteName }],
    ['meta', { property: 'og:description', content: tagline }],
    ['meta', { property: 'og:url', content: siteUrl }],
    ['meta', { property: 'og:image', content: ogImage }],
    ['meta', { property: 'og:image:width', content: '1200' }],
    ['meta', { property: 'og:image:height', content: '630' }],
    ['meta', { property: 'og:image:alt', content: `${siteName} — ${tagline}` }],
    ['meta', { property: 'article:author', content: siteAuthor }],
    ['meta', { property: 'article:published_time', content: publishedDate }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
    ['meta', { name: 'twitter:title', content: siteName }],
    ['meta', { name: 'twitter:description', content: tagline }],
    ['meta', { name: 'twitter:image', content: ogImage }],
  ],
  rewrites: {
    'docs/README.md': 'docs/index.md',
    'labs/README.md': 'labs/index.md',
    'labs/:lab/README.md': 'labs/:lab/index.md',
    'labs/:lab/:section/README.md': 'labs/:lab/:section/index.md',
    'labs/:lab/:section/:subsection/README.md': 'labs/:lab/:section/:subsection/index.md',
    'modules/README.md': 'modules/index.md',
    'modules/:provider/:module/README.md': 'modules/:provider/:module/index.md',
    'engagements/README.md': 'engagements/index.md',
    'pre-sales/README.md': 'pre-sales/index.md',
    'internal/README.md': 'internal/index.md',
    'reference-app/README.md': 'reference-app/index.md',
  },
  markdown: {
    theme: {
      light: 'github-light',
      dark: 'github-dark',
    },
    config(md) {
      const defaultFence = md.renderer.rules.fence

      md.renderer.rules.fence = (tokens, idx, options, env, self) => {
        const token = tokens[idx]
        const language = token.info.trim().split(/\s+/)[0]

        if (language === 'mermaid') {
          return `<pre class="mermaid">${md.utils.escapeHtml(token.content)}</pre>`
        }

        return defaultFence
          ? defaultFence(tokens, idx, options, env, self)
          : self.renderToken(tokens, idx, options)
      }
    },
  },
  themeConfig: {
    logo: '/logo.svg',
    outline: { level: [2, 3], label: 'On this page' },
    search: {
      provider: 'local',
      options: {
        detailedView: true,
      },
    },
    nav: [
      { text: 'Start Here', link: '/START-HERE' },
      { text: 'Labs', link: '/labs/' },
      { text: 'Modules', link: '/modules/' },
      { text: 'Diagrams', link: '/VISUAL-DIAGRAMS' },
      {
        text: 'Guides',
        items: [
          { text: 'Content Index', link: '/CONTENT-INDEX' },
          { text: 'Learning Paths', link: '/LEARNING-PATHS' },
          { text: 'Documentation Index', link: '/docs/' },
          { text: 'Project Status', link: '/PROJECT-STATUS' },
        ],
      },
      seriesNav,
    ],
    sidebar: {
      '/labs/': [{ text: 'Labs', items: labs }],
      '/modules/': [{ text: 'Modules', items: modules }],
      '/docs/02-multi-cloud/': [{ text: 'Multi-Cloud', items: multiCloud }],
      '/docs/05-operations/': [{ text: 'Operations', items: operations }],
      '/docs/': [
        { text: 'Guides', items: guides },
        { text: 'Multi-Cloud', items: multiCloud },
        { text: 'Operations', items: operations },
      ],
      '/': [
        { text: 'Start', items: guides },
        { text: 'Labs', collapsed: true, items: labs },
        { text: 'Modules', collapsed: true, items: modules },
      ],
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/WBHankins93/implementation-studio' },
    ],
    editLink: {
      pattern: 'https://github.com/WBHankins93/implementation-studio/edit/main/:path',
      text: 'Edit this page on GitHub',
    },
    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Implementation Studio - constrained deployment patterns, infrastructure modules, and customer-ready guides.',
    },
  },
})
