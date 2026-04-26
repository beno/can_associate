defmodule CanAssociate.AgentManagementService do
  @moduledoc """
  Service layer for managing agents and their work package associations.
  """

  alias CanAssociate.Agents.Agent
  alias CanAssociate.AgentStore

  @spec create_agent(map()) :: {:ok, Agent.t()} | {:error, term()}
  def create_agent(attrs) when is_map(attrs) do
    with {:ok, agent} <- Agent.new(attrs),
         {:ok, stored_agent} <- AgentStore.insert(agent) do
      {:ok, stored_agent}
    end
  end

  @spec fetch_agent(String.t()) :: {:ok, Agent.t()} | {:error, term()}
  def fetch_agent(agent_id), do: AgentStore.fetch(agent_id)

  @spec list_agents() :: [Agent.t()]
  def list_agents, do: AgentStore.list()

  @spec list_agents_for_model(String.t()) :: [Agent.t()]
  def list_agents_for_model(model_id) when is_binary(model_id) do
    normalized_model_id = String.trim(model_id)

    AgentStore.list()
    |> Enum.filter(&(&1.model_id == normalized_model_id))
  end

  @spec associate_work_package(String.t(), String.t()) :: {:ok, Agent.t()} | {:error, term()}
  def associate_work_package(agent_id, work_package_id) do
    with {:ok, agent} <- AgentStore.fetch(agent_id),
         {:ok, updated_agent} <- Agent.associate_work_package(agent, work_package_id),
         {:ok, stored_agent} <- AgentStore.replace(updated_agent) do
      {:ok, stored_agent}
    end
  end

  @spec dissociate_work_package(String.t(), String.t()) :: {:ok, Agent.t()} | {:error, term()}
  def dissociate_work_package(agent_id, work_package_id) do
    with {:ok, agent} <- AgentStore.fetch(agent_id),
         {:ok, updated_agent} <- Agent.dissociate_work_package(agent, work_package_id),
         {:ok, stored_agent} <- AgentStore.replace(updated_agent) do
      {:ok, stored_agent}
    end
  end

  @spec delete_agent(String.t()) :: {:ok, Agent.t()} | {:error, term()}
  def delete_agent(agent_id), do: AgentStore.delete(agent_id)

  @doc false
  def reset!, do: AgentStore.reset()
end
