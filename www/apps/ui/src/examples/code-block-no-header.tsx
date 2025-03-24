import { CodeBlock } from "@medusajs/ui"

const snippets = [
  {
    label: "Medusa JS SDK",
    language: "jsx",
    code: `// Install the JS SDK in your storefront project: @medusajs/js-sdk\n\nimport Medusa from "@medusajs/js-sdk"\n\nconst medusa = new Medusa({\n  baseUrl: import.meta.env.NEXT_PUBLIC_BACKEND_URL || "/",\n  publishableKey: process.env.NEXT_PUBLIC_MEDUSA_PAK\n})\nconst { product } = await medusa.store.products.retrieve("prod_123")\nconsole.log(product.id)`,
  },
]

export default function CodeBlockNoHeader() {
  return (
    <div className="w-full">
      <CodeBlock snippets={snippets}>
        <CodeBlock.Body />
      </CodeBlock>
    </div>
  )
}
