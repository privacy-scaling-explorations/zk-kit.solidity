import { existsSync, readFileSync, writeFileSync } from "node:fs"

async function main() {
    let dotIndex = process.argv[2].lastIndexOf(".")

    let folderName = dotIndex !== -1 ? process.argv[2].slice(0, dotIndex) : process.argv[2]

    const projectDirectory = `packages/${folderName}`

    let filePath = `${projectDirectory}/package.json`

    if (existsSync(`${projectDirectory}/contracts/package.json`)) {
        filePath = `${projectDirectory}/contracts/package.json`
    }

    const content = JSON.parse(readFileSync(filePath, "utf8"))

    if (content.stableVersion) {
        delete content.stableVersion
    }

    writeFileSync(filePath, JSON.stringify(content, null, 4), "utf8")
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
