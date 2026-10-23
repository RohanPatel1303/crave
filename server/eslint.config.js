import tseslint from 'typescript-eslint';

export default tseslint.config(
  tseslint.configs.strictTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService: {
          allowDefaultProject: ["src/*.test.ts"],
        },
        tsconfigRootDir: import.meta.dirname,
      },
    },
  },
);
