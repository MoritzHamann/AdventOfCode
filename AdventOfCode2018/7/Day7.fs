module Day7
    open System.Text.RegularExpressions

    type Instruction = {step: string; requirement: string} with
        static member Parse line =
            let m = Regex.Match(line, "Step (\w) must be finished before step (\w) can begin.")
            {requirement = m.Groups.[1].Value; step = m.Groups.[2].Value}

    type Node = {name: string; pre: string list; post: string list; finished: bool} with
        member this.addReqs reqs =
            {this with pre=List.append this.pre reqs}

        member this.removeReq req =
            {this with pre=List.filter (fun i -> i <> req) this.pre}

        member this.removeReqs reqs =
            {this with pre=List.filter (fun i -> not(List.contains i reqs)) this.pre}

        member this.addPosts posts =
            {this with post=List.append this.post posts}

        member this.markFinished() = {this with finished=true}

    let part1 instructions =
        // builds the base map of all nodes, setting only the "name"
        let nodeMap =
            instructions
            |> List.collect (fun i -> [i.step; i.requirement])
            |> List.distinct
            |> List.map (fun name -> name, {name=name; pre=[]; post=[]; finished=false})
            |> Map.ofList

        // update requirements for each node 
        let nodeMap =
            (nodeMap, instructions)
            ||> List.fold (fun map i ->
                let preNode:Node = Map.find i.requirement map
                let postNode:Node = Map.find i.step map
                let map = Map.add i.requirement (preNode.addPosts [i.step]) map
                let map = Map.add i.step (postNode.addReqs [i.requirement]) map
                map)
    
        // find all nodes which can be executed (have no requirements and are not yet done)
        let available nodes =
            Map.toList nodes
            |> List.filter (fun (name, node) -> List.isEmpty node.pre)
            |> List.filter (fun (name, node) -> not(node.finished))

        let selectNext num nodes =
            let av = available nodes
            let num = min (List.length av) num
            av |> List.sort |> List.take num |> List.map snd

        let markDone finishedNodes (nodes:Map<string, Node>) =
                finishedNodes
                |> List.fold (fun map n ->
                    let node:Node = Map.find n map
                    Map.add n (node.markFinished()) map) nodes
        
        let removedReqs finishedNodes (nodes:Map<string,Node>) =
            Map.map (fun name (node:Node) ->
                node.removeReqs finishedNodes) nodes
        
        let rec advance nodes result = 
            match selectNext 1 nodes with
            | [] -> List.rev result
            | nextNodes ->
                let nextNodesNames = List.map (fun n -> n.name) nextNodes
                let updatedNodes = nodes |> markDone nextNodesNames |> removedReqs nextNodesNames
                advance updatedNodes (List.append nextNodesNames result)
        // find the final ordering
        advance nodeMap [] |> String.concat ""
 
    let part2 instructions =
        ""

    let solution filename =
        let depenencies =
            System.IO.File.ReadLines filename
            |> Seq.map Instruction.Parse
            |> Seq.toList

        part1 depenencies |> printf "%A\n"
        part2 depenencies |> printf "%A\n"
