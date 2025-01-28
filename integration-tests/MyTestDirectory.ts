// Note: This file is autogenerated. Do not edit it directly.
//
// Describes the contents of the test directory, which is a blueprint for
// files and directories. Tests can create a unique, safe environment for
// interacting with the contents of such a directory.
//
// Having strong typing for the test directory contents ensures that tests can
// be written with confidence that the files and directories they expect are
// actually found. Otherwise the tests are brittle and can break easily.

import { z } from "zod"

export const MyTestDirectorySchema = z.object({
  name: z.literal("test-environment/"),
  type: z.literal("directory"),
  contents: z.object({
    ".config": z.object({
      name: z.literal(".config/"),
      type: z.literal("directory"),
      contents: z.object({
        nvim: z.object({
          name: z.literal("nvim/"),
          type: z.literal("directory"),
          contents: z.object({
            "init.lua": z.object({
              name: z.literal("init.lua"),
              type: z.literal("file"),
            }),
            "prepare.lua": z.object({
              name: z.literal("prepare.lua"),
              type: z.literal("file"),
            }),
          }),
        }),
      }),
    }),
    "config-modifications": z.object({
      name: z.literal("config-modifications/"),
      type: z.literal("directory"),
      contents: z.object({
        "disable_project_root_fallback.lua": z.object({
          name: z.literal("disable_project_root_fallback.lua"),
          type: z.literal("file"),
        }),
        "don't_use_debug_mode.lua": z.object({
          name: z.literal("don't_use_debug_mode.lua"),
          type: z.literal("file"),
        }),
        "set_ignore_paths.lua": z.object({
          name: z.literal("set_ignore_paths.lua"),
          type: z.literal("file"),
        }),
        "use_case_sensitive_search.lua": z.object({
          name: z.literal("use_case_sensitive_search.lua"),
          type: z.literal("file"),
        }),
        "use_manual_mode.lua": z.object({
          name: z.literal("use_manual_mode.lua"),
          type: z.literal("file"),
        }),
        "use_not_found_project_root.lua": z.object({
          name: z.literal("use_not_found_project_root.lua"),
          type: z.literal("file"),
        }),
      }),
    }),
    "initial-file.txt": z.object({
      name: z.literal("initial-file.txt"),
      type: z.literal("file"),
    }),
    limited: z.object({
      name: z.literal("limited/"),
      type: z.literal("directory"),
      contents: z.object({
        "dir with spaces": z.object({
          name: z.literal("dir with spaces/"),
          type: z.literal("directory"),
          contents: z.object({
            "file with spaces.txt": z.object({
              name: z.literal("file with spaces.txt"),
              type: z.literal("file"),
            }),
            "other file with spaces.txt": z.object({
              name: z.literal("other file with spaces.txt"),
              type: z.literal("file"),
            }),
          }),
        }),
        "main-project-file.lua": z.object({
          name: z.literal("main-project-file.lua"),
          type: z.literal("file"),
        }),
        subproject: z.object({
          name: z.literal("subproject/"),
          type: z.literal("directory"),
          contents: z.object({
            "example.clj": z.object({
              name: z.literal("example.clj"),
              type: z.literal("file"),
            }),
            "file1.lua": z.object({
              name: z.literal("file1.lua"),
              type: z.literal("file"),
            }),
            "file2.lua": z.object({
              name: z.literal("file2.lua"),
              type: z.literal("file"),
            }),
            "file3.lua": z.object({
              name: z.literal("file3.lua"),
              type: z.literal("file"),
            }),
          }),
        }),
      }),
    }),
    "line-file.lua": z.object({
      name: z.literal("line-file.lua"),
      type: z.literal("file"),
    }),
    "other-file.lua": z.object({
      name: z.literal("other-file.lua"),
      type: z.literal("file"),
    }),
  }),
})

export const MyTestDirectoryContentsSchema =
  MyTestDirectorySchema.shape.contents
export type MyTestDirectoryContentsSchemaType = z.infer<
  typeof MyTestDirectorySchema
>

export type MyTestDirectory = MyTestDirectoryContentsSchemaType["contents"]

export const testDirectoryFiles = z.enum([
  ".config/nvim/init.lua",
  ".config/nvim/prepare.lua",
  ".config/nvim",
  ".config",
  "config-modifications/disable_project_root_fallback.lua",
  "config-modifications/don't_use_debug_mode.lua",
  "config-modifications/set_ignore_paths.lua",
  "config-modifications/use_case_sensitive_search.lua",
  "config-modifications/use_manual_mode.lua",
  "config-modifications/use_not_found_project_root.lua",
  "config-modifications",
  "initial-file.txt",
  "limited/dir with spaces/file with spaces.txt",
  "limited/dir with spaces/other file with spaces.txt",
  "limited/dir with spaces",
  "limited/main-project-file.lua",
  "limited/subproject/example.clj",
  "limited/subproject/file1.lua",
  "limited/subproject/file2.lua",
  "limited/subproject/file3.lua",
  "limited/subproject",
  "limited",
  "line-file.lua",
  "other-file.lua",
  ".",
])
export type MyTestDirectoryFile = z.infer<typeof testDirectoryFiles>
