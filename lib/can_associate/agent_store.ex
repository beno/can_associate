defmodule CanAssociate.AgentStore do
  @moduledoc false

  use GenServer

  alias CanAssociate.Agents.Agent

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def insert(%Agent{} = agent) do
    GenServer.call(__MODULE__, {:insert, agent})
  end

  def fetch(agent_id) do
    GenServer.call(__MODULE__, {:fetch, agent_id})
  end

  def list do
    GenServer.call(__MODULE__, :list)
  end

  def replace(%Agent{} = agent) do
    GenServer.call(__MODULE__, {:replace, agent})
  end

  def delete(agent_id) do
    GenServer.call(__MODULE__, {:delete, agent_id})
  end

  def reset do
    GenServer.call(__MODULE__, :reset)
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:insert, %Agent{id: id} = agent}, _from, state) do
    case Map.has_key?(state, id) do
      true -> {:reply, {:error, {:agent_already_exists, id}}, state}
      false -> {:reply, {:ok, agent}, Map.put(state, id, agent)}
    end
  end

  def handle_call({:fetch, agent_id}, _from, state) do
    case Map.fetch(state, agent_id) do
      {:ok, agent} -> {:reply, {:ok, agent}, state}
      :error -> {:reply, {:error, {:agent_not_found, agent_id}}, state}
    end
  end

  def handle_call(:list, _from, state) do
    agents =
      state
      |> Map.values()
      |> Enum.sort_by(& &1.id)

    {:reply, agents, state}
  end

  def handle_call({:replace, %Agent{id: id} = agent}, _from, state) do
    case Map.has_key?(state, id) do
      true -> {:reply, {:ok, agent}, Map.put(state, id, agent)}
      false -> {:reply, {:error, {:agent_not_found, id}}, state}
    end
  end

  def handle_call({:delete, agent_id}, _from, state) do
    case Map.pop(state, agent_id) do
      {nil, _state} -> {:reply, {:error, {:agent_not_found, agent_id}}, state}
      {agent, new_state} -> {:reply, {:ok, agent}, new_state}
    end
  end

  def handle_call(:reset, _from, _state) do
    {:reply, :ok, %{}}
  end
end
