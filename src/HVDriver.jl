module HVDriver

using CSV
using GLMakie
using Colors
using EasyFit


export import_oscope, import_spice, import_teensy
export CurrentSensor, HVSensor, ADC

greet() = print("Hello World!")



clr = [
    parse(RGBAf, "#C80051"), # maroon (OneNote)
    parse(RGBAf, "#7E2F8E"), # purple
    parse(RGBAf, "#0072BD"), # blue
    parse(RGBAf, "#D95319"), # orange/red
    parse(RGBAf, "#EDB120"), # yellow
    parse(RGBAf, "#009E73FF"), # teal
    parse(RGBAf, "#E71225"), # red (OneNote)
    parse(RGBAf, "#F6630D"), # orange (OneNote)
    parse(RGBAf, "#FFC000"), # yellow (OneNote)
    parse(RGBAf, "#329597"), # teal (OneNote)
]

gray1 = parse(RGBAf, "#8E8A73") # light
gray2 = parse(RGBAf, "#272822") # dark

update_theme!(palette = (color = clr,), linewidth=2)



# import n channels of oscope data from filename
# returns a tuple of vectors, starting with time in μs, followed by raw data
function import_oscope(filename, n)

    # fname = "data/oscope_20230224/NewFile6.csv"
    channels = ["CH$i" for i in 1:n]
    file = CSV.File(filename; header=1,limit=1, silencewarnings=true)
    dt = file.Increment .* 1e6 # convert to μs
    
    file = CSV.File(filename; header=["time", channels..., "junk"], skipto=3, drop=[5])
    time = file.time .* dt
    
    return (time, [Vector(getproperty(file, ch)) for ch in Symbol.(channels)]...)
end

# import n channels of teensy data from filename
# returns a tuple of vectors, starting with time in μs, followed by raw data
function import_teensy(filename, n)
end


function import_spice(filename)
end


## structs for interpreting raw sensor data
abstract type AbstractSensor end

struct CurrentSensor <: AbstractSensor
    G # sensor gain (V/V)
    Rs # shunt resistor (Ω)
    Vs # supply voltage (V)
    Vr # reference voltage
end

# return mA from raw sensor reading x
(A::CurrentSensor)(x) = 1000 * (x-A.Vr)/(A.Rs*A.G)

# default to Vr at 50% of Vs
CurrentSensor(G,Rs,Vs) = CurrentSensor(G,Rs,Vs,Vs/2)



struct HVSensor <: AbstractSensor
    G # sensor gain (V/V)
end

# returns kV
(A::HVSensor)(x) = x/(G*1000)


struct ADC <: AbstractSensor
    bits # ADC resolution
end

# return V from raw bits x
(A::ADC)(x) = 3.3 * x/A.bits



end # module HVDriver
