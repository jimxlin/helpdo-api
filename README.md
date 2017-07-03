# HelpDo API

HelpDo is a social platform for creating and sharing todo lists. This API authenticates with JWT via [knock](https://github.com/nsarno/knock). For detailed information on the endpoints, consult [routes.rb](/config/routes) and the [controllers folder](/controllers).

## Friends

Friends are added through the friend request system.

## Private Todo Lists

Private todo lists cannot be shared with others, but their tasks can be made visible to friends, and users can give credit to friends that have helped with a task.

## Public Todo Lists

Public todo lists operate like group projects. Members of a public todo list with admin access can add or remove members, assign members to tasks, and mark tasks as done. The creator of the list is a permanent admin.
