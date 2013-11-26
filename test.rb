Facter.fact(:network).resolution(:linux_names) do

  confine :kernel => :linux

  resolve do
    net = {}
    Dir.glob('/sys/class/net/*').map { |d| File.basename(d) }.each do |bla|
      net[bla] = {}
    end

    net
  end
end

Facter.fact(:network).resolution(:linux, :using => [:linux_names]) do

  resolve do |net|
    net.each_pair do |name, properties|
      properties[:macaddress] = File.read("/sys/class/net/#{name}/address").chomp
    end

    net
  end
end

Facter.fact(:network).resolution(:linux_mtu, :using => [:linux_names]) do

  resolve do |net|
    net.each_pair do |name, properties|
      properties[:mtu] = File.read("/sys/class/net/#{name}/mtu").chomp.to_i
    end

    net
  end
end

Facter.fact(:network).resolution(:linux_jumbo, :using => [:linux_names, :linux_mtu]) do

  resolve do |net|
    net.each_pair do |name, properties|
      properties[:jumbo] = properties[:mtu] > 1500
    end

    net
  end
end
