import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
	plugins: [sveltekit()],
	build: {
		target: 'esnext',
		commonjsOptions: {
			include: [/linked-dep/, /node_modules/],
		},
	},
	// esbuild: {
	// 	supported: {
	// 		'top-level-await': true
	// 	},
	// }
	optimizeDeps: {
		include: ['linked-dep'],
	},
});
