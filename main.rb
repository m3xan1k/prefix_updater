domains = [
  "example.com",
  "example.com",
  "example.com",
]


def get_ips(domain)
  dig_answer = %x[dig #{domain}].split(";;").select{ |section| section.include? "ANSWER SECTION" }.first
  answer_array = dig_answer.split("\n")
  
  if dig_answer.include? "CNAME"
    resolves = answer_array[2..]
  else
    resolves = answer_array[1..]
  end
  
  ips = resolves.map{ |resolve| resolve.split(" ").last }
  return ips
end


def main(domains)
  prefixes = Array.new
  
  domains.each do |domain|
    ips = get_ips(domain)
    routes = ips.map{ |ip| "route #{ip}/32 reject;"}
    prefixes.push(*routes)
  end
  
  prefixes_string = prefixes.join("\n") + "\n"
  
  File.write("prefixes.lst", prefixes_string)
end


main(domains)

