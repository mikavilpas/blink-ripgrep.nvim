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
  name: z.literal("test-environment"),
  type: z.literal("directory"),
  contents: z.object({
    "initial-file.txt": z.object({
      name: z.literal("initial-file.txt"),
      type: z.literal("file"),
      extension: z.literal("txt"),
      stem: z.literal("initial-file."),
    }),
    "other-file.lua": z.object({
      name: z.literal("other-file.lua"),
      type: z.literal("file"),
      extension: z.literal("lua"),
      stem: z.literal("other-file."),
    }),
    "test-setup.lua": z.object({
      name: z.literal("test-setup.lua"),
      type: z.literal("file"),
      extension: z.literal("lua"),
      stem: z.literal("test-setup."),
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
  "initial-file.txt",
  "other-file.lua",
  "test-setup.lua",
  ".",
])
export type MyTestDirectoryFile = z.infer<typeof testDirectoryFiles>
