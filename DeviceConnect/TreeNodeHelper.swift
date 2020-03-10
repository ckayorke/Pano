
import Foundation
class TreeNodeHelper {
    class var sharedInstance: TreeNodeHelper {
        struct Static {
            static var instance: TreeNodeHelper? = TreeNodeHelper()

        }
        return Static.instance!
    }
    
    func getSortedNodes(_ groups: [DataNode], defaultExpandLevel: Int) -> [TreeNode] {
        var result: [TreeNode] = []
        let nodes = convetData2Node(groups)
        let rootNodes = getRootNodes(nodes)
        for item in rootNodes{
            addNode(&result, node: item, defaultExpandLeval: defaultExpandLevel, currentLevel: 1)
        }
        
        return result
    }
    
    func filterVisibleNode(_ nodes: [TreeNode]) -> [TreeNode] {
        var result: [TreeNode] = []
        for item in nodes {
            if item.isRoot() || item.isParentExpand() {
                setNodeIcon(item)
                result.append(item)
            }
        }
        return result
    }
    
    func convetData2Node(_ groups: [DataNode]) -> [TreeNode] {
        var nodes: [TreeNode] = []
        
        var node: TreeNode
        var desc: String?
        var id: String?
        var pId: String?
        var label: String?
        var main: Bool?
        
        for item in groups {
            //let item = element as? [String:Any]
            desc = item.description
            id = item.id
            pId = item.pid
            label = item.name
            main = item.mainNode
            node = TreeNode(desc: desc, id: id, pId: pId, name: label, mainNode: main!)
            nodes.append(node)
        }
        
        var n: TreeNode
        var m: TreeNode
        for i in 0 ..< nodes.count {
            n = nodes[i]
            
            for j in i+1 ..< nodes.count {
                m = nodes[j]
                if m.pId == n.id {
                    n.children.append(m)
                    m.parent = n
                }
                else if n.pId == m.id {
                    m.children.append(n)
                    n.parent = m
                }
            }
        }
        for item in nodes {
            setNodeIcon(item)
        }
        
        return nodes
    }
    
    func getRootNodes(_ nodes: [TreeNode]) -> [TreeNode] {
        var root: [TreeNode] = []
        for item in nodes {
            if item.isRoot() {
                root.append(item)
            }
        }
        return root
    }
    
    func addNode(_ nodes: inout [TreeNode], node: TreeNode, defaultExpandLeval: Int, currentLevel: Int) {
        nodes.append(node)
        if defaultExpandLeval >= currentLevel {
            node.setExpand(true)
        }
        if node.isLeaf() {
            return
        }
        for i in 0 ..< node.children.count {
            addNode(&nodes, node: node.children[i], defaultExpandLeval: defaultExpandLeval, currentLevel: currentLevel+1)
        }
    }
    
    func setNodeIcon(_ node: TreeNode) {
        if node.children.count > 0 {
            node.type = TreeNode.NODE_TYPE_G
            if node.isExpand {
                node.icon = "tree_ex.png"
            } else if !node.isExpand {
                node.icon = "tree_ec.png"
            }
        } else {
            node.type = TreeNode.NODE_TYPE_N
        }
    }
}
