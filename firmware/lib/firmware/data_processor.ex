defmodule Firmware.DataProcessor do
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
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @doc """
  Process test data (lux sensor values) to determine if light was detected.
  """
  @spec process_data([integer], [integer], [integer]) ::
          {:ok, {boolean, String.t()}} | {:error, atom}
  def process_data(data_values_1, data_values_2, data_values_3) do
    args = [data_values_1, data_values_2, data_values_3]
    GenServer.call(__MODULE__, {:process_data, args})
  end

  # GenServer callbacks

  @impl GenServer
  def init(_opts) do
    # TODO: control the lifecycle of the erlports Python process, whether via a
    # supervisor or by trapping its exit from this process, etc.
    {:ok, python_session} =
      :python.start(python_path: :code.priv_dir(:python_algo), python: 'python')

    {:ok, %State{python_session: python_session}}
  end

  @impl GenServer
  def handle_call({:process_data, process_data_args}, _from, state)
      when is_list(process_data_args) do
    {bool, string} =
      :python.call(state.python_session, :process_data, :process_data, process_data_args)

    {:reply, {:ok, {bool, string}}, state}
  end
end
