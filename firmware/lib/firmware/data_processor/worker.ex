defmodule Firmware.DataProcessor.Worker do
  @moduledoc """
  Public API for processing data.
  """
  use GenServer

  defmodule State do
    @moduledoc false
    @enforce_keys [:python_session]
    defstruct @enforce_keys
  end

  @spec start_link(any) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Process test data (lux sensor values) to determine if light was detected.
  """
  @spec process_data(pid, [integer], [integer], [integer]) ::
          {:ok, {boolean, String.t()}} | {:error, atom}
  def process_data(python, data_values_1, data_values_2, data_values_3) do
    args = [data_values_1, data_values_2, data_values_3]
    GenServer.call(__MODULE__, {:process_data, python, args})
  end

  # GenServer callbacks

  @impl GenServer
  def init(_opts) do
    # {:ok, python_session} =
    #   :python.start(python_path: :code.priv_dir(:python_algo), python: 'python')
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:process_data, python_session, process_data_args}, _from, state)
      when is_list(process_data_args) do
    {bool, string} = :python.call(python_session, :process_data, :process_data, process_data_args)

    {:reply, {:ok, {bool, string}}, state}
  end
end
