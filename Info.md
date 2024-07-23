#  <#Title#>

________ GraphDescription ________
AVAudioEngineGraph 0x2825dfa00: initialized = 0, running = 0, number of nodes = 3

     ******** output chain ********

     node 0x2837ce900 {auou rioc appl}, 'U'
         inputs = 1
             (bus0, en1) <- (bus0) 0x2837ccc80, {aumx mcmx appl}, [ 2 ch,  44100 Hz, Float32, deinterleaved]

     node 0x2837ccc80 {aumx mcmx appl}, 'U'
         outputs = 1
             (bus0, en1) -> (bus0) 0x2837ce900, {auou rioc appl}, [ 2 ch,  44100 Hz, Float32, deinterleaved]

     ******** input chain ********

     node 0x2837e9600 {auou rioc appl}, 'U'
______________________________________






________ GraphDescription ________
AVAudioEngineGraph 0x28251f900: initialized = 0, running = 0, number of nodes = 3

     ******** output chain ********

     node 0x28376d680 {auou rioc appl}, 'U'
         inputs = 1
             (bus0, en1) <- (bus0) 0x28376d500, {aumx mcmx appl}, [ 2 ch,  44100 Hz, Float32, deinterleaved]

     node 0x28376d500 {aumx mcmx appl}, 'U'
         inputs = 1
             (bus0, en1) <- (bus1) 0x28377e280, {auou rioc appl}, [ 1 ch,  44100 Hz, Float32]
         outputs = 1
             (bus0, en1) -> (bus0) 0x28376d680, {auou rioc appl}, [ 2 ch,  44100 Hz, Float32, deinterleaved]

     node 0x28377e280 {auou rioc appl}, 'U'
         outputs = 2
             (bus0, en0) -> (bus0) 0x0, {}, [ 1 ch,  44100 Hz, Float32]
             (bus1, en1) -> (bus0) 0x28376d500, {aumx mcmx appl}, [ 1 ch,  44100 Hz, Float32]

     ******** input chain ********

     node 0x28377e280 {auou rioc appl}, 'U'
         outputs = 2
             (bus0, en0) -> (bus0) 0x0, {}, [ 1 ch,  44100 Hz, Float32]
             (bus1, en1) -> (bus0) 0x28376d500, {aumx mcmx appl}, [ 1 ch,  44100 Hz, Float32]

     node 0x28376d500 {aumx mcmx appl}, 'U'
         inputs = 1
             (bus0, en1) <- (bus1) 0x28377e280, {auou rioc appl}, [ 1 ch,  44100 Hz, Float32]
         outputs = 1
             (bus0, en1) -> (bus0) 0x28376d680, {auou rioc appl}, [ 2 ch,  44100 Hz, Float32, deinterleaved]

     node 0x28376d680 {auou rioc appl}, 'U'
         inputs = 1
             (bus0, en1) <- (bus0) 0x28376d500, {aumx mcmx appl}, [ 2 ch,  44100 Hz, Float32, deinterleaved]
______________________________________


