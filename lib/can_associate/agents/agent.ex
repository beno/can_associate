defmodule CanAssociate.Agents.Agent do
  @moduledoc """
  Domain model for the `Agent (Plot - Agents)` data object.
  """

  @enforce_keys [:id, :model_id, :work_package_ids]
  defstruct [:id, :model_id, :work_package_ids]

  @type t :: %__MODULE__{
          id: String.t(),
          model_id: String.t(),
          work_package_ids: [String.t()]
        }

  @spec new(map()) :: {:ok, t()} | {:error, term()}
  def new(attrs) when is_map(attrs) do
    attrs = normalize_keys(attrs)

    with :ok <- reject_unknown_keys(attrs),
         {:ok, model_id} <- validate_required_string(attrs, :model_id),
         {:ok, id} <- validate_optional_string(attrs, :id, generate_id()),
         {:ok, work_package_ids} <-
           validate_work_package_ids(Map.get(attrs, :work_package_ids, [])) do
      {:ok,
       %__MODULE__{
         id: id,
         model_id: model_id,
         work_package_ids: work_package_ids
       }}
    end
  end

  @spec associate_work_package(t(), String.t()) :: {:ok, t()} | {:error, term()}
  def associate_work_package(%__MODULE__{} = agent, work_package_id) do
    with {:ok, validated_id} <- validate_non_empty_string(:work_package_id, work_package_id) do
      updated_ids =
        agent.work_package_ids
        |> Kernel.++([validated_id])
        |> Enum.uniq()

      {:ok, %{agent | work_package_ids: updated_ids}}
    end
  end

  @spec dissociate_work_package(t(), String.t()) :: {:ok, t()} | {:error, term()}
  def dissociate_work_package(%__MODULE__{} = agent, work_package_id) do
    with {:ok, validated_id} <- validate_non_empty_string(:work_package_id, work_package_id) do
      updated_ids = Enum.reject(agent.work_package_ids, &(&1 == validated_id))
      {:ok, %{agent | work_package_ids: updated_ids}}
    end
  end

  defp normalize_keys(attrs) do
    Enum.reduce(attrs, %{}, fn
      {key, value}, acc when is_atom(key) -> Map.put(acc, key, value)
      {key, value}, acc when is_binary(key) -> Map.put(acc, normalize_string_key(key), value)
    end)
  end

  defp normalize_string_key("id"), do: :id
  defp normalize_string_key("model_id"), do: :model_id
  defp normalize_string_key("work_package_ids"), do: :work_package_ids
  defp normalize_string_key(key), do: key

  defp reject_unknown_keys(attrs) do
    allowed_keys = MapSet.new([:id, :model_id, :work_package_ids])

    unknown_keys =
      attrs
      |> Map.keys()
      |> Enum.reject(&MapSet.member?(allowed_keys, &1))

    case unknown_keys do
      [] -> :ok
      keys -> {:error, {:unknown_attributes, Enum.sort(keys)}}
    end
  end

  defp validate_required_string(attrs, key) do
    validate_non_empty_string(key, Map.get(attrs, key))
  end

  defp validate_optional_string(attrs, key, default) do
    case Map.get(attrs, key, default) do
      nil -> {:ok, default}
      value -> validate_non_empty_string(key, value)
    end
  end

  defp validate_work_package_ids(ids) when is_list(ids) do
    ids
    |> Enum.reduce_while({:ok, []}, fn id, {:ok, acc} ->
      case validate_non_empty_string(:work_package_id, id) do
        {:ok, validated_id} -> {:cont, {:ok, [validated_id | acc]}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, validated_ids} -> {:ok, validated_ids |> Enum.reverse() |> Enum.uniq()}
      error -> error
    end
  end

  defp validate_work_package_ids(_), do: {:error, {:invalid_type, :work_package_ids}}

  defp validate_non_empty_string(field, value) when is_binary(value) do
    trimmed = String.trim(value)

    if trimmed == "" do
      {:error, {:required, field}}
    else
      {:ok, trimmed}
    end
  end

  defp validate_non_empty_string(field, nil), do: {:error, {:required, field}}
  defp validate_non_empty_string(field, _value), do: {:error, {:invalid_type, field}}

  defp generate_id do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
  end
end
