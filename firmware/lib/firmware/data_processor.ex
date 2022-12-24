defmodule Firmware.DataProcessor do
  use Supervisor
  alias Firmware.DataProcessor.Worker

  @supervisor __MODULE__

  def child_spec(opts) do
    opts = Keyword.put_new(opts, :name, @supervisor)

    %{
      id: opts[:name],
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(opts) do
    name = opts[:name] || raise ArgumentError, "name is required"
    Supervisor.start_link(__MODULE__, opts, name: name)
  end

  def process_data(supervisor \\ @supervisor, data_values_1, data_values_2, data_values_3) do
    python =
      Supervisor.which_children(supervisor)
      |> Enum.find_value(fn {module, pid, _, _} -> if module == :python, do: pid end)

    Worker.process_data(python, data_values_1, data_values_2, data_values_3)
  end

  @impl Supervisor
  def init(_opts) do
    children = [
      %{
        id: :python,
        start:
          {:python, :start_link, [[python_path: :code.priv_dir(:python_algo), python: 'python']]}
      },
      {Worker, []}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
