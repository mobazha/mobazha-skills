import * as path from "node:path";
import * as fs from "node:fs";

function getBootstrapContent() {
  const skillPath = path.resolve(
    import.meta.dirname,
    "../../skills/using-mobazha/SKILL.md",
  );
  try {
    return fs.readFileSync(skillPath, "utf-8");
  } catch {
    return null;
  }
}

export const MobazhaSkillsPlugin = async () => {
  const skillsDir = path.resolve(import.meta.dirname, "../../skills");

  return {
    config: async (config) => {
      config.skills = config.skills || {};
      config.skills.paths = config.skills.paths || [];
      if (!config.skills.paths.includes(skillsDir)) {
        config.skills.paths.push(skillsDir);
      }
    },
    "experimental.chat.messages.transform": async (_input, output) => {
      const bootstrap = getBootstrapContent();
      if (!bootstrap || !output.messages.length) return;

      const firstUser = output.messages.find((m) => m.info.role === "user");
      if (!firstUser || !firstUser.parts.length) return;
      if (
        firstUser.parts.some(
          (p) => p.type === "text" && p.text.includes("MOBAZHA_SKILLS_LOADED"),
        )
      )
        return;

      const ref = firstUser.parts[0];
      firstUser.parts.unshift({
        ...ref,
        type: "text",
        text: `<!-- MOBAZHA_SKILLS_LOADED -->\n${bootstrap}`,
      });
    },
  };
};
