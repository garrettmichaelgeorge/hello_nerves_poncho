defmodule Firmware.DataProcessorTest do
  use ExUnit.Case, async: true

  alias Firmware.DataProcessor

  test "smoke test" do
    assert {:ok, _doesnt_matter} = DataProcessor.process_data(1, 2, 3)
  end
end
