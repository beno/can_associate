# CanAssociate

Minimal Elixir implementation of the **Agent Management Service** work package from the Agent Execution Pipeline model.

## What is implemented

This repository provides a focused service for the `Agent (Plot - Agents)` data object:

- create and retrieve agents
- list all agents
- list agents for a model
- associate an agent with one or more work packages
- dissociate an agent from a work package
- delete agents

The implementation keeps the domain model intentionally small so it stays aligned with the architecture graph:

- an agent belongs to a `model_id`
- an agent can be associated with zero or more `work_package_ids`

## Run tests

```bash
mix test
```
