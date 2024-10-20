# README

## Steps taken to solve
1. Setup Boilerplate rails application using `rails new birds-api --api -d postgresql`
2. Delete extra goodies we don't need (ActionCable, Etc)
3. Unzip nodes.csv.gz using `gzip -d data/nodes.csv.gz`
4. Create the database `bundle exec rake db:create`
5. Create the model using `rails g model nodes`
6. Create the table using `bundle exec rake db:migrate`
   * Note, I decided not to use foreign key constraints as in the future we may need to add children before their parents.
7. Seed the initial data using `rails db:seed`
8. Choose `acts_as_tree` gem to handle self references
9. Add `parents`, `root`, and `lowest_common_ancestor` methods to the model
10. Add `rspec` & `rubocop`
11. Create the api contoller using `rails g controller CommonAncestors`
12. Update the `config/routes.rb`
13. Add the birds model using `rails g model Bird`
14. Add the birds controller using `rails g controller Birds`
15. Use Rubocop to clean up code
16. Add specs to handle cyclical trees.

## Model Selection
Decide between the following ways to model the self referencing relationship
   1. Using `acts_as_tree` gem provides the following out of the box
      1. `parent` and `children` relationships
      2. `descendants`, `self_and_descendants`, `parents`, and `self_and_parents` instance methods
      3. While testing i encountered and error when processing cyclical branches. To fix this i modified the implementation of `parents` and `descendents` to handle cyclical relationships
   2. Using `acts_as_sane_tree` allows this recursion to be built into postgres using recursive queries, however I decided not to take this route for various reasons
      1. Recursive queries are harder to read and debug.
      2. May cause unecessary load on the db.
      3. Down the line this is probally more efficient however i would wrap these recursive queries in stored procures.

## Getting Started
1. Clone repo
2. Install the required gems `bundle install`
3. Create the database `bundle exec rake db:create`
4. Perform migrations `bundle exec rake db:migrate`
5. Start Server `rails s`

## Testing
1. run `bundle exec rspec` to run all specs

### Initial Test Data 
Initial Test data is provided in the `spec/spec_helper.rb`
```
def setup_data
  Node.create!(id: 7, parent_id: 6)
  Node.create!(id: 6, parent_id: nil)
  Node.create!(id: 2, parent_id: 7)
  Node.create!(id: 4, parent_id: 7)
  Node.create!(id: 8, parent_id: 7)
  Node.create!(id: 5, parent_id: 4)

  Node.create!(id: 9, parent_id: 12)
  Node.create!(id: 10, parent_id: 9)
  Node.create!(id: 11, parent_id: 10)
  Node.create!(id: 12, parent_id: 11)

  Bird.create!(id: 101, node_id: 2)
  Bird.create!(id: 102, node_id: 4)
  Bird.create!(id: 103, node_id: 5)
  Bird.create!(id: 104, node_id: 6)
  Bird.create!(id: 105, node_id: 5)
end
```

### Visualization of Test Data

```mermaid
---
config:
  layout: dagre
  look: classic
  theme: base
---
flowchart TD
    classDef err color:#dc3545,stroke:#dc3545,fill:#fac8cd;
    classDef ok color:#35dc89,stroke:#35dc89,fill:#e8ffed;
    subgraph Cyclic
    G((Node 9)) --> H((Node 10))
    H((Node 10)) --> I((Node 11))
    I((Node 11)) --> J((Node 12))
    J((Node 12)) == Cyclical ==> G((Node 9))
    end
    subgraph "Acyclic (Normal)"
    A((Node 6)) -- child --> B((Node 7))
    B((Node 7)) --> C((Node 2))
    B((Node 7)) --> D((Node 4))
    B((Node 7)) --> E((Node 8))
    D((Node 4)) --> F((Node 5))
    
    C((Node 2)) --> Z{{Bird 101}}:::err
    D((Node 4)) --> Y{{Bird 102}}:::err
    F((Node 5)) --> X{{Bird 103}}:::err
    A((Node 6)) --> W{{Bird 104}}:::err
    F((Node 5)) --> V{{Bird 105}}:::err
    end
```