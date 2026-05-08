import Foundation

let args = CommandLine.arguments.dropFirst()

if args.first == "--help" || args.first == "-h" {
    let commands = Commands(useProtocol: false)
    exit(commands.run(["help"]))
}

if let initMsg = FledgeProtocol.readInit(), initMsg.type == "init" {
    let subArgs = initMsg.args ?? Array(args)
    let commands = Commands(useProtocol: true)
    exit(commands.run(subArgs))
} else {
    let commands = Commands(useProtocol: false)
    exit(commands.run(Array(args)))
}
