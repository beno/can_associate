defmodule CanAssociate do
  @moduledoc """
  Entry point for the Agent Management Service work package.
  """

  alias CanAssociate.AgentManagementService

  defdelegate create_agent(attrs), to: AgentManagementService
  defdelegate fetch_agent(agent_id), to: AgentManagementService
  defdelegate list_agents(), to: AgentManagementService
  defdelegate list_agents_for_model(model_id), to: AgentManagementService
  defdelegate associate_work_package(agent_id, work_package_id), to: AgentManagementService
  defdelegate dissociate_work_package(agent_id, work_package_id), to: AgentManagementService
  defdelegate delete_agent(agent_id), to: AgentManagementService
end
