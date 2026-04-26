defmodule CanAssociate.AgentManagementServiceTest do
  use ExUnit.Case, async: false

  alias CanAssociate.AgentManagementService

  setup do
    AgentManagementService.reset!()
    :ok
  end

  test "creates an agent for a model" do
    assert {:ok, agent} = AgentManagementService.create_agent(%{model_id: "model-1"})

    assert agent.model_id == "model-1"
    assert is_binary(agent.id)
    assert String.length(agent.id) == 32
    assert agent.work_package_ids == []
  end

  test "rejects agents without a model identifier" do
    assert {:error, {:required, :model_id}} =
             AgentManagementService.create_agent(%{})
  end

  test "lists agents for a specific model" do
    assert {:ok, agent_one} = AgentManagementService.create_agent(%{model_id: "model-1"})
    assert {:ok, _agent_two} = AgentManagementService.create_agent(%{model_id: "model-2"})
    assert {:ok, agent_three} = AgentManagementService.create_agent(%{model_id: "model-1"})

    assert AgentManagementService.list_agents_for_model("model-1") ==
             Enum.sort_by([agent_one, agent_three], & &1.id)
  end

  test "associates a work package with an agent once" do
    assert {:ok, agent} = AgentManagementService.create_agent(%{model_id: "model-1"})

    assert {:ok, updated_agent} =
             AgentManagementService.associate_work_package(agent.id, "work-package-1")

    assert {:ok, updated_agent_again} =
             AgentManagementService.associate_work_package(agent.id, "work-package-1")

    assert updated_agent.work_package_ids == ["work-package-1"]
    assert updated_agent_again.work_package_ids == ["work-package-1"]
  end

  test "dissociates a work package from an agent" do
    assert {:ok, agent} =
             AgentManagementService.create_agent(%{
               model_id: "model-1",
               work_package_ids: ["work-package-1", "work-package-2"]
             })

    assert {:ok, updated_agent} =
             AgentManagementService.dissociate_work_package(agent.id, "work-package-1")

    assert updated_agent.work_package_ids == ["work-package-2"]
  end

  test "deletes an agent" do
    assert {:ok, agent} = AgentManagementService.create_agent(%{model_id: "model-1"})
    assert {:ok, deleted_agent} = AgentManagementService.delete_agent(agent.id)
    assert deleted_agent.id == agent.id

    assert {:error, {:agent_not_found, missing_agent_id}} =
             AgentManagementService.fetch_agent(agent.id)

    assert missing_agent_id == agent.id
  end

  test "rejects duplicate agent identifiers" do
    assert {:ok, _agent} =
             AgentManagementService.create_agent(%{id: "agent-1", model_id: "model-1"})

    assert {:error, {:agent_already_exists, "agent-1"}} =
             AgentManagementService.create_agent(%{id: "agent-1", model_id: "model-1"})
  end
end
