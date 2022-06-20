import svelte from 'rollup-plugin-svelte';
import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import livereload from 'rollup-plugin-livereload';
import { terser } from 'rollup-plugin-terser';
import {default as sveltePreprocess, scss} from 'svelte-preprocess';
import typescript from '@rollup/plugin-typescript';
import css from 'rollup-plugin-css-only';
import styles from 'rollup-plugin-styles';
import replace from 'rollup-plugin-replace';
import { string } from 'rollup-plugin-string';
import { apiPath } from './tf.config'

const production = !process.env.ROLLUP_WATCH;


function serve() {
	let server;

	function toExit() {
		if (server) server.kill(0);
	}

	return {
		writeBundle() {
			if (server) return;
			server = require('child_process').spawn('npm', ['run', 'start', '--', '--dev'], {
				stdio: ['ignore', 'inherit', 'inherit'],
				shell: true
			});

			process.on('SIGTERM', toExit);
			process.on('exit', toExit);
		}
	};
}

export default [
	{
		input: 'src/main.ts',
		output: {
			sourcemap: true,
			format: 'iife',
			name: 'app',
			file: 'public/build/bundle.js'
		},
		plugins: [
			svelte({
				preprocess: sveltePreprocess({ sourceMap: !production }),
				compilerOptions: {
					dev: !production,
					accessors: true
				}
			}),
			css({ output: 'bundle.css' }),
			resolve({
				browser: true,
				dedupe: ['svelte']
			}),
			commonjs(),
			replace({
				exclude: 'node_modules/**',
				APP_ENV: JSON.stringify(production && 'production' || 'development'),
				API_PATH: JSON.stringify(apiPath),
			}),
			typescript({
				sourceMap: !production,
				inlineSources: !production
			}),
			!production && serve(),
			!production && livereload('public'),
			production && terser()
		],
		watch: {
			clearScreen: false
		}
	},
	{
		input: 'src/carbon-lite.scss',
		output: { dir: 'public/build', format: 'es', },
		plugins: [resolve(), styles({mode: 'extract', minimize: true})],
	},
	{
		input: 'src/PublicApp.svelte',
		output: {
			sourcemap: true,
			format: 'es',
			file: 'public/build/PublicApp.js'
		},
		plugins: [
			svelte({
				preprocess: [sveltePreprocess({sourceMap: !production})],
				compilerOptions: {
					dev: !production,
					accessors: true,
				},
			}),
			css({ output: 'PublicApp.css' }),
			resolve({
				browser: true,
				dedupe: ['svelte']
			}),
			commonjs(),
			replace({
				exclude: 'node_modules/**',
				APP_ENV: JSON.stringify(production && 'production' || 'development'),
				API_PATH: JSON.stringify(`${apiPath}/public`),
				APP_URL: apiPath,
			}),
			typescript({
				sourceMap: !production,
				inlineSources: !production}),
		]
	},
	{
		input: 'src/public-main.ts',
		output: {
			sourcemap: true,
			format: 'es',
			file: 'public/build/PublicRetroBoard.js'
		},
		plugins: [
			string({include: "**/*.css"}),
			typescript({
				sourceMap: !production,
				inlineSources: !production}),
			!production && serve(),
			!production && livereload('public'),
			production && terser()
		]
	}
];
