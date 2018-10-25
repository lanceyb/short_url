defmodule ShortUrl.Redix do
  @pool_size 10

  def child_spec(_args) do
    # Specs for the Redix connections.
    children =
      for i <- 0..(@pool_size - 1) do
        opts = [{:name, :"redix_#{i}"} | Application.fetch_env!(:redix, :args)]
        #Supervisor.child_spec({Redix, host: "localhost", port: 6379, name: :"redix_#{i}"}, id: {Redix, i})
        Supervisor.child_spec({Redix, opts}, id: {Redix, i})
      end

    # Spec for the supervisor that will supervise the Redix connections.
    %{
      id: RedixSupervisor,
      type: :supervisor,
      start: {Supervisor, :start_link, [children, [strategy: :one_for_one]]}
    }
  end

  def command(command) do
    Redix.command(:"redix_#{random_index()}", command)
  end

  defp random_index() do
    rem(System.unique_integer([:positive]), @pool_size)
  end
end
