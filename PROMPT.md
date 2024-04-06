At dataPlor we write software that deals with exponentially expanding data. We are looking for people who can take novel problems, demonstrate first principles design and performance that flows from deep understanding, and integrate that into best practices code quality and organization.

This code challenge is designed to test your decision making while trying to not write a lot of code or take a ton of time. That said, we do value clean, well organized code.

There's no set deadline, take as much time as you think you need and let us know when to expect it. 

Our objective is to assess how you think about, approach, and solve novel problems, so to the extent that you want to include a README about your thinking that you feel might not come through in the code about directions you considered but didn't implement, that helps us as well.

## The ask
We have an adjacency list that creates a tree of nodes where a child's `parent_id` = a parent's `id`. We have provided some sample data in the attached csv.

Please make an api (rails, sinatra, cuba--your choice) that has two endpoints: 

### 1. Common Ancestor 
`/nodes/:node_a_id/common_ancestors/:node_b_id` - It should return the `root_id`, `lowest_common_ancestor_id`, and `depth` of tree of the lowest common ancestor that those two node ids share.

For example, given the data for nodes:
```
   id    | parent_id
---------+-----------
     125 |       130
     130 |          
 2820230 |       125
 4430546 |       125
 5497637 |   4430546
```

`/nodes/5497637/common_ancestors/2820230` should return
`{root_id: 130, lowest_common_ancestor: 125, depth: 2}`

`/nodes/5497637/common_ancestors/130` should return
`{root_id: 130, lowest_common_ancestor: 130, depth: 1}`

`/nodes/5497637/common_ancestors/4430546` should return
`{root_id: 130, lowest_common_ancestor: 4430546, depth: 3}`

if there is no common node match, return null for all fields

`/nodes/9/common_ancestors/4430546` should return
`{root_id: null, lowest_common_ancestor: null, depth: null}`

if a==b, it should return itself

`/nodes/4430546/common_ancestors/4430546` should return
`{root_id: 130, lowest_common_ancestor: 4430546, depth: 3}`

### 2. Birds

Another endpoint `/birds` - The second requirement for this project involves considering a second model, birds. Nodes have_many birds and birds belong_to nodes. Our second endpoint should take a list of `node_ids` and return the ids of the birds that belong to one of those nodes or any descendant nodes.

## Additional Notes

The most efficient way to narrowly solve this problem probably involves pre-processing the data and then serving that pre-processed data, but we are not interested in a narrow solution. So I would like you to assume that a different process will add to the data (with no assumption as to the magnitude of the additions). Your solution should be optimized for a system that could expand to billions of nodes. 


