import { Sidebar } from "types"

const getDefaultSidebar = async () =>
  import("@/generated/generated-resources-sidebar.mjs") as Promise<{
    default: Sidebar.Sidebar
  }>

const sidebarMappings: {
  module: () => Promise<{ default: Sidebar.Sidebar }>
  paths: string[]
}[] = [
  {
    module: async () =>
      import("@/generated/generated-recipes-sidebar.mjs") as Promise<{
        default: Sidebar.Sidebar
      }>,
    paths: ["/recipes/"],
  },
  {
    module: async () =>
      import("@/generated/generated-how-to-tutorials-sidebar.mjs") as Promise<{
        default: Sidebar.Sidebar
      }>,
    paths: [
      "/how-to-tutorials",
      "/examples",
      "/admin-components",
      "/plugins/guides",
      "/deployment",
    ],
  },
]
export async function getSidebarForPath(
  currentPath: string
): Promise<Sidebar.Sidebar> {
  const sidebarMapping = sidebarMappings.find(({ paths }) =>
    paths.some((path) => {
      if (currentPath.startsWith(path)) {
        return true
      }

      const regex = new RegExp(`^${path.replace(/\/$/, "")}(/|$)`)
      return regex.test(currentPath)
    })
  )

  if (sidebarMapping) {
    const sidebarModule = await sidebarMapping.module()
    return sidebarModule.default
  }

  return await getDefaultSidebar().then((module) => module.default)
}
