import { defineConfig } from 'vite';

export default defineConfig({
  base: '/sysrev/',
  server: {
    host: '0.0.0.0',
    port: 5173,
    strictPort: true,
    watch: {
      usePolling: true,
    },
    proxy: {
      // em dev, chamadas para /sysrev/api/* vão direto ao backend
      '/sysrev/api': {
        target: 'http://backend:9500',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/sysrev\/api/, ''),
      },
    },
  },
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    sourcemap: true,
  },
});