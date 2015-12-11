# rb_jstat2gf

It is a Ruby clone of jstat2gf(https://github.com/kazeburo/jstat2gf)

## Installation

```
$ gem install rb_jstat2gf
```

## Usage

```
$ rb_jstat2gf --url=your.gf.host.name --port=5125 --service=aaa --section=hive --prefix=hs2 --pid=$(pgrep -of HiveServer2)
```

## Requirements
* Java 8

## Contributing

1. Fork it ( https://github.com/wyukawa/rb_jstat2gf/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
