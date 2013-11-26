Facter.fact(:network).resolution(:linux) do

  confine :kernel => :linux

  resolve(:names) do
    net = {}
    Dir.glob('/sys/class/net/*').map { |d| File.basename(d) }.each do |bla|
      net[bla] = {}
    end

    net
  end
end

Facter.fact(:network).resolution(:linux) do

  resolve(:macaddress, :using => [:names]) do |net|
    net.each_pair do |name, properties|
      properties[:macaddress] = File.read("/sys/class/net/#{name}/address").chomp
    end

    net
  end
end

Facter.fact(:network).resolution(:linux) do

  resolve(:mtu, :using => [:names]) do |net|

    net.each_pair do |name, properties|
      properties[:mtu] = File.read("/sys/class/net/#{name}/mtu").chomp.to_i
    end

    net
  end
end

Facter.fact(:network).resolution(:linux) do

  resolve(:jumbo, :using => [:names, :mtu]) do |net|
    net.each_pair do |name, properties|
      properties[:jumbo] = properties[:mtu] > 1500
    end

    net
  end
end
