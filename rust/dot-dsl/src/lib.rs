pub mod graph {
    use std::collections::HashMap;
    use crate::graph::graph_items::edge::Edge;
    use crate::graph::graph_items::node::Node;

    pub mod graph_items {

        pub mod edge {
            use std::collections::HashMap;

            #[derive(Clone, PartialEq, Debug)]
            pub struct Edge {
                start: String,
                end: String,
                attrs: HashMap<String, String>,
            }
            
            impl Edge {
                pub fn new(start: &str, end: &str) -> Self {
                    Edge {
                        start: start.to_string(),
                        end: end.to_string(),
                        attrs: HashMap::new(),
                    }
                }

                pub fn with_attrs(self, attrs: &[(&str, &str)]) -> Self {
                    let attrs = attrs.iter()
                        .map(|&(key, value)| (key.to_string(), value.to_string()))
                        .collect();
                    Self {
                        attrs,
                        ..self
                    }
                }

                pub fn attr(&self, key: &str) -> Option<&str> {
                    self.attrs.get(key).map(|value| value.as_str())
                }
            }
        }

        pub mod node {
            use std::collections::HashMap;

            #[derive(Clone, PartialEq, Debug)]
            pub struct Node<> {
                pub(crate) value: String,
                attrs: HashMap<String, String>,
            }

            impl Node {
                pub fn new(value: &str) -> Self {
                    Node { value: value.to_string(), attrs: HashMap::new() }
                }

                pub fn with_attrs(self, attrs: &[(&str, &str)]) -> Self {
                    let attrs = attrs.iter()
                        .map(|&(key, value)| (key.to_string(), value.to_string()))
                        .collect();
                    Self {
                        attrs,
                        ..self
                    }
                }

                pub fn attr(&self, key: &str) -> Option<&str> {
                    self.attrs.get(key).map(|value| value.as_str())
                }
            }
        }
    }

    pub struct Graph {
        pub nodes: Vec<Node>,
        pub edges: Vec<Edge>,
        pub attrs: HashMap<String, String>,
    }

    impl Graph {

        pub fn new() -> Self {
            Graph {
                nodes: vec![],
                edges: vec![],
                attrs: HashMap::new(),
            }
        }

        pub fn with_nodes(self, nodes: &[Node]) -> Self {
            Graph {
                nodes: nodes.to_vec(),
                ..self
            }
        }
        
        pub fn with_edges(self, edges: &[Edge]) -> Self {
            Graph {
                edges: edges.to_vec(),
                ..self
            }
        }

        pub fn with_attrs(self, attrs: &[(&str, &str)]) -> Self {
            let attrs = attrs.iter()
                .map(|&(key, value)| (key.to_string(), value.to_string()))
                .collect();
            Self {
                attrs,
                ..self
            }
        }
        
        pub fn node(&self, value: &str) -> Option<&Node> {
            self.nodes.iter().find(|&node| node.value == value)
        }
    }
}
