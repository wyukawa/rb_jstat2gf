require "rb_jstat2gf/version"
require 'optparse'
require 'growthforecast'

def exec_jstat(option, pid)
  jstat_path="jstat"
  command = "#{jstat_path} #{option} #{pid}"
  io = IO.popen(command, "r")
  lines = io.readlines()
  io.close
  headers = lines[0].split()
  datas = lines[1].split()

  record = Hash.new
  headers.each_with_index{|header, i|
    record[header] = datas[i].to_f
  }

  record
end

option={}
OptionParser.new do |opt|
  opt.on("--url=url", "")   {|v| option[:url] = v}
  opt.on("--port=port", "")   {|v| option[:port] = v}
  opt.on("--service=service", "")   {|v| option[:service] = v}
  opt.on("--section=section", "")   {|v| option[:section] = v}
  opt.on("--prefix=prefix", "")   {|v| option[:prefix] = v}
  opt.on("--pid=pid", "")   {|v| option[:pid] = v}
  
  opt.parse!(ARGV)
end

url = option[:url]
port = option[:port]
service = option[:service]
section = option[:section]
prefix = option[:prefix]
pid = option[:pid]

gccapacity = exec_jstat("-gccapacity", pid)
gcold = exec_jstat("-gcold", pid)
gcnew = exec_jstat("-gcnew", pid)
gc = exec_jstat("-gc", pid)

gf = GrowthForecast.new(url, port)

new_max = gf.post(service, section, prefix + "_new_max", gccapacity["NGCMX"].to_i, 'gauge', '#1111cc')
new_commit = gf.post(service, section, prefix + "_new_commit", gccapacity["NGC"].to_i, 'gauge', '#11cc11')
old_max = gf.post(service, section, prefix + "_old_max", gccapacity["OGCMX"].to_i, 'gauge', '#1111cc')
old_commit = gf.post(service, section, prefix + "_old_commit", gccapacity["OGC"].to_i, 'gauge', '#11cc11')
meta_max = gf.post(service, section, prefix + "_meta_max", gccapacity["MCMX"].to_i, 'gauge', '#1111cc')
meta_commit = gf.post(service, section, prefix + "_meta_commit", gccapacity["MC"].to_i, 'gauge', '#11cc11')

meta_used = gf.post(service, section, prefix + "_meta_used", gcold["MU"].to_i, 'gauge', '#cccc77')
old_used = gf.post(service, section, prefix + "_old_used", gcold["OU"].to_i, 'gauge', '#cccc77')

sv0_used = gf.post(service, section, prefix + "_sv0_used", gcnew["S0U"].to_i, 'gauge', '#952d57')
sv1_used = gf.post(service, section, prefix + "_sv1_used", gcnew["S1U"].to_i, 'gauge', '#f9d475')
eden_used = gf.post(service, section, prefix + "_eden_used", gcnew["EU"].to_i, 'gauge', '#dd923c')

fgc_times = gf.post(service, section, prefix + "_fgc_times", gc["FGC"].to_i, 'gauge', '#7020AF')
fgc_sec = gf.post(service, section, prefix + "_fgc_sec", gc["FGCT"]*1000, 'gauge', '#F0B300')

complex_new = GrowthForecast::Complex.new({
  complex: true,
  service_name: service, section_name: section, graph_name: prefix + "_new",
  description: "JVM memory KB (new)",
  sort: 19
})
new_commit_item = GrowthForecast::Complex::Item.new({graph_id: new_commit.id, type: 'AREA', gmode: 'gauge', stack: false})
complex_new.data.push(new_commit_item)
new_max_item = GrowthForecast::Complex::Item.new({graph_id: new_max.id, type: 'LINE1', gmode: 'gauge', stack: false})
complex_new.data.push(new_max_item)
sv0_used_item = GrowthForecast::Complex::Item.new({graph_id: sv0_used.id, type: 'AREA', gmode: 'gauge', stack: false})
complex_new.data.push(sv0_used_item)
sv1_used_item = GrowthForecast::Complex::Item.new({graph_id: sv1_used.id, type: 'AREA', gmode: 'gauge', stack: true})
complex_new.data.push(sv1_used_item)
eden_used_item = GrowthForecast::Complex::Item.new({graph_id: eden_used.id, type: 'AREA', gmode: 'gauge', stack: true})
complex_new.data.push(eden_used_item)
gf.add(complex_new)

complex_metaspace = GrowthForecast::Complex.new({
  complex: true,
  service_name: service, section_name: section, graph_name: prefix + "_metaspace",
  description: "JVM memory KB (metaspace)",
  sort: 17
})
meta_commit_item = GrowthForecast::Complex::Item.new({graph_id: meta_commit.id, type: 'AREA', gmode: 'gauge', stack: false})
complex_metaspace.data.push(meta_commit_item)
meta_max_item = GrowthForecast::Complex::Item.new({graph_id: meta_max.id, type: 'LINE1', gmode: 'gauge', stack: false})
complex_metaspace.data.push(meta_max_item)
meta_used_item = GrowthForecast::Complex::Item.new({graph_id: meta_used.id, type: 'AREA', gmode: 'gauge', stack: false})
complex_metaspace.data.push(meta_used_item)
gf.add(complex_metaspace)

complex_old = GrowthForecast::Complex.new({
  complex: true,
  service_name: service, section_name: section, graph_name: prefix + "_old",
  description: "JVM memory KB (old)",
  sort: 18
})
old_commit_item = GrowthForecast::Complex::Item.new({graph_id: old_commit.id, type: 'AREA', gmode: 'gauge', stack: false})
complex_old.data.push(old_commit_item)
old_max_item = GrowthForecast::Complex::Item.new({graph_id: old_max.id, type: 'LINE1', gmode: 'gauge', stack: false})
complex_old.data.push(old_max_item)
old_used_item = GrowthForecast::Complex::Item.new({graph_id: old_used.id, type: 'AREA', gmode: 'gauge', stack: false})
complex_old.data.push(old_used_item)
gf.add(complex_old)
