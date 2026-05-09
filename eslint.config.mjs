import js from "@eslint/js";
import prettier from "eslint-config-prettier";

export default [
    // Ignore build artifacts, vendor, and generated files
    {
        ignores: [
            "vendor/**",
            "node_modules/**",
            "public/**",
            "bootstrap/**",
            "storage/**",
            "scripts/**",
            "*.config.js",
            "webpack.mix.js",
            "vite-module-loader.js",
            "resources/js/lara-builder/**",
        ],
    },

    // Base recommended rules
    js.configs.recommended,

    // Prettier disables formatting rules that conflict with prettier
    prettier,

    // App browser JS
    {
        files: ["resources/**/*.js", "resources/**/*.mjs"],
        languageOptions: {
            ecmaVersion: 2022,
            sourceType: "module",
            globals: {
                // Browser
                window: "readonly",
                document: "readonly",
                console: "readonly",
                navigator: "readonly",
                location: "readonly",
                localStorage: "readonly",
                sessionStorage: "readonly",
                setTimeout: "readonly",
                clearTimeout: "readonly",
                setInterval: "readonly",
                clearInterval: "readonly",
                requestAnimationFrame: "readonly",
                cancelAnimationFrame: "readonly",
                MutationObserver: "readonly",
                IntersectionObserver: "readonly",
                ResizeObserver: "readonly",
                Promise: "readonly",
                FormData: "readonly",
                URLSearchParams: "readonly",
                fetch: "readonly",
                alert: "readonly",
                confirm: "readonly",
                Event: "readonly",
                CustomEvent: "readonly",
                HTMLElement: "readonly",
                // App globals
                Alpine: "readonly",
                Livewire: "readonly",
                axios: "readonly",
            },
        },
        rules: {
            "no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
            "no-console": "off",
        },
    },
];
