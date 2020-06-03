##
## environment
##

using Pkg
Pkg.add("XLSX")
Pkg.add("DataFrames")
Pkg.add("Printf")
Pkg.add("DelimitedFiles")
using XLSX
using DataFrames
using Printf
using DelimitedFiles

##
## data
##

## data name
const dname = "MPVDatasetDownload.xlsx"

## get data from `https://mappingpoliceviolence.org/s/MPVDatasetDownload.xlsx`
run(`./getdata`)

## load datafile
xf  = XLSX.readxlsx("MPVDatasetDownload.xlsx")
dfs = Dict()
for n in XLSX.sheetnames(xf)
    df = DataFrame(XLSX.readtable(dname, n)...)
    dfs[n] = df
end

##
## summary
##

function get_summary_state(dfs::Dict, state::String, years::Float64=7.0)
    ## setup
    for k in XLSX.sheetnames(xf)
        @assert(haskey(dfs, k))
    end
    # pk  = dfs["2013-2019 Police Killings"]
    # kpd = dfs["2013-2019 Killings by PD"]
    kbs = dfs["2013-2019 Killings by State"]
    # pkbm = dfs["Police Killings of Black Men"]

    ## add to df
    kbs.avg_all_kill_py_pMM = kbs."# People Killed"       ./ years ./ (kbs.Population               ./ 1e6)
    kbs.avg_blk_kill_py_pMM = kbs."# Black people killed" ./ years ./ (kbs."African-American Alone" ./ 1e6)
    kbs.blk_v_all_kill_py_pMM_x = kbs.avg_blk_kill_py_pMM ./ kbs.avg_all_kill_py_pMM  ## "black avg kill rate = Z.ZZx all kill rate"
    p = sortperm(sortperm(kbs.avg_all_kill_py_pMM, rev=true))
    kbs.avg_all_kill_py_pMM_rk = p
    p = sortperm(sortperm(kbs.avg_blk_kill_py_pMM, rev=true))
    kbs.avg_blk_kill_py_pMM_rk = p

    ## summarize
    state_row               = kbs[kbs.State .== state, :]
    all_pop                 = first(state_row.Population)
    blk_pop                 = first(state_row."African-American Alone")
    blk_pop_pct             = blk_pop ./ all_pop
    all_kill                = first(state_row."# People Killed")
    blk_kill                = first(state_row."# Black people killed")
    avg_all_kill_py_pMM     = first(state_row.avg_all_kill_py_pMM)
    avg_all_kill_py_pMM_rk  = first(state_row.avg_all_kill_py_pMM_rk)
    avg_blk_kill_py_pMM     = first(state_row.avg_blk_kill_py_pMM)
    avg_blk_kill_py_pMM_rk  = first(state_row.avg_blk_kill_py_pMM_rk)
    avg_blk_kill_py         = blk_kill ./ years
    pct_blk_victims         = blk_kill ./ all_kill
    disparity_pct           = pct_blk_victims - blk_pop_pct
    blk_v_all_kill_py_pMM_x = first(state_row.blk_v_all_kill_py_pMM_x)

    ## return
    out = Dict()
    out[:type] = :state
    out[:state] = ismissing(state) ? 0.0 : state
    out[:all_pop] = ismissing(all_pop) ? 0.0 : all_pop
    out[:blk_pop] = ismissing(blk_pop) ? 0.0 : blk_pop
    out[:blk_pop_pct] = ismissing(blk_pop_pct) ? 0.0 : blk_pop_pct
    out[:all_kill] = ismissing(all_kill) ? 0.0 : all_kill
    out[:blk_kill] = ismissing(blk_kill) ? 0.0 : blk_kill
    out[:avg_all_kill_py_pMM] = ismissing(avg_all_kill_py_pMM) ? 0.0 : avg_all_kill_py_pMM
    out[:avg_all_kill_py_pMM_rk] = ismissing(avg_all_kill_py_pMM_rk) ? 0.0 : avg_all_kill_py_pMM_rk
    out[:avg_blk_kill_py_pMM] = ismissing(avg_blk_kill_py_pMM) ? 0.0 : avg_blk_kill_py_pMM
    out[:avg_blk_kill_py_pMM_rk] = ismissing(avg_blk_kill_py_pMM_rk) ? 0.0 : avg_blk_kill_py_pMM_rk
    out[:avg_blk_kill_py] = ismissing(avg_blk_kill_py) ? 0.0 : avg_blk_kill_py
    out[:pct_blk_victims] = ismissing(pct_blk_victims) ? 0.0 : pct_blk_victims
    out[:disparity_pct] = ismissing(disparity_pct) ? 0.0 : disparity_pct
    out[:blk_v_all_kill_py_pMM_x] = ismissing(blk_v_all_kill_py_pMM_x) ? 0.0 : blk_v_all_kill_py_pMM_x
    return out
end

function get_summary_city(dfs::Dict, city::String, years::Float64=7.0)
    ## setup
    for k in XLSX.sheetnames(xf)
        @assert(haskey(dfs, k))
    end
    # pk  = dfs["2013-2019 Police Killings"]
    kpd = dfs["2013-2019 Killings by PD"]
    # kbs = dfs["2013-2019 Killings by State"]
    # pkbm = dfs["Police Killings of Black Men"]

    ## add to df
    kpd.avg_all_kill_py_pMM = kpd."All People Killed by Police (1/1/2013-12/31/2019)"   ./ years ./ (kpd.Total ./ 1e6)
    kpd.avg_blk_kill_py_pMM = kpd."Black People Killed by Police (1/1/2013-12/31/2019)" ./ years ./ (kpd.Black ./ 1e6)
    kpd.blk_v_all_kill_py_pMM_x = kpd.avg_blk_kill_py_pMM ./ kpd.avg_all_kill_py_pMM  ## "black avg kill rate = Z.ZZx all kill rate"
    p = sortperm(sortperm(kpd.avg_all_kill_py_pMM, rev=true))
    kpd.avg_all_kill_py_pMM_rk = p
    p = sortperm(sortperm(kpd.avg_blk_kill_py_pMM, rev=true))
    kpd.avg_blk_kill_py_pMM_rk = p

    ## summarize
    city_row                = kpd[kpd.City .== city, :]
    # state                   = first(city_row.state)
    all_pop                 = first(city_row.Total)
    blk_pop                 = first(city_row.Black)
    blk_pop_pct             = blk_pop ./ all_pop
    all_kill                = first(city_row."All People Killed by Police (1/1/2013-12/31/2019)")
    blk_kill                = first(city_row."Black People Killed by Police (1/1/2013-12/31/2019)")
    avg_all_kill_py_pMM     = first(city_row.avg_all_kill_py_pMM)
    avg_all_kill_py_pMM_rk  = first(city_row.avg_all_kill_py_pMM_rk)
    avg_blk_kill_py_pMM     = first(city_row.avg_blk_kill_py_pMM)
    avg_blk_kill_py_pMM_rk  = first(city_row.avg_blk_kill_py_pMM_rk)
    avg_blk_kill_py         = blk_kill ./ years
    pct_blk_victims         = blk_kill ./ all_kill
    disparity_pct           = pct_blk_victims - blk_pop_pct
    blk_v_all_kill_py_pMM_x = first(city_row.blk_v_all_kill_py_pMM_x)
    civ_mur_rate_pMM        = first(city_row."Murder Rate")
    pol_hom_rate_pMM        = first(city_row."Avg Annual Police Homicide Rate")
    all_kill_rate_as_pct_murder_rate = pol_hom_rate_pMM / civ_mur_rate_pMM
    kill_p10k_arrests       = first(city_row."Killings by Police per 10k Arrests")

    ## return
    out = Dict()
    out[:type] = :city
    out[:city] = ismissing(city) ? 0.0 : city
    out[:all_pop] = ismissing(all_pop) ? 0.0 : all_pop
    out[:blk_pop] = ismissing(blk_pop) ? 0.0 : blk_pop
    out[:blk_pop_pct] = ismissing(blk_pop_pct) ? 0.0 : blk_pop_pct
    out[:all_kill] = ismissing(all_kill) ? 0.0 : all_kill
    out[:blk_kill] = ismissing(blk_kill) ? 0.0 : blk_kill
    out[:avg_all_kill_py_pMM] = ismissing(avg_all_kill_py_pMM) ? 0.0 : avg_all_kill_py_pMM
    out[:avg_all_kill_py_pMM_rk] = ismissing(avg_all_kill_py_pMM_rk) ? 0.0 : avg_all_kill_py_pMM_rk
    out[:avg_blk_kill_py_pMM] = ismissing(avg_blk_kill_py_pMM) ? 0.0 : avg_blk_kill_py_pMM
    out[:avg_blk_kill_py_pMM_rk] = ismissing(avg_blk_kill_py_pMM_rk) ? 0.0 : avg_blk_kill_py_pMM_rk
    out[:avg_blk_kill_py] = ismissing(avg_blk_kill_py) ? 0.0 : avg_blk_kill_py
    out[:pct_blk_victims] = ismissing(pct_blk_victims) ? 0.0 : pct_blk_victims
    out[:disparity_pct] = ismissing(disparity_pct) ? 0.0 : disparity_pct
    out[:blk_v_all_kill_py_pMM_x] = ismissing(blk_v_all_kill_py_pMM_x) ? 0.0 : blk_v_all_kill_py_pMM_x
    out[:civ_mur_rate_pMM] = ismissing(civ_mur_rate_pMM) ? 0.0 : civ_mur_rate_pMM
    out[:pol_hom_rate_pMM] = ismissing(pol_hom_rate_pMM) ? 0.0 : pol_hom_rate_pMM
    out[:all_kill_rate_as_pct_murder_rate] = ismissing(all_kill_rate_as_pct_murder_rate) ? 0.0 : all_kill_rate_as_pct_murder_rate
    out[:kill_p10k_arrests] = ismissing(kill_p10k_arrests) ? 0.0 : kill_p10k_arrests
    return out
end

function display_summary_state(out::Dict)
    s = ""
    s *= out[:state] * ": Jan. 2013 - Dec. 2019" * "\n"
    s *= "Population: $(@sprintf("%.2f mil.", (out[:all_pop]/1e6)))" * "\n"
    s *= "Total killed by police: $(@sprintf("%d", out[:all_kill]))" * "\n"
    s *= "Blacks killed by police: $(@sprintf("%d", out[:blk_kill]))" * "\n"
    s *= "Avg. killed/yr. (per mil.): $(@sprintf("%.1f", out[:avg_all_kill_py_pMM])), rank: $(@sprintf("%d", out[:avg_all_kill_py_pMM_rk]))" * "\n"
    s *= "Avg. Blacks killed/yr. (per mil.): $(@sprintf("%.1f", out[:avg_blk_kill_py_pMM])), rank: $(@sprintf("%d", out[:avg_blk_kill_py_pMM_rk]))" * "\n"
    s *= "Blacks killed rate = $(@sprintf("%.2fx", out[:blk_v_all_kill_py_pMM_x])) all killed rate" * "\n"
    s *= "Black pop. proportion: $(@sprintf("%.1f", 100out[:blk_pop_pct]))%" * "\n"
    s *= "Black killed proportion: $(@sprintf("%.1f", 100out[:pct_blk_victims]))%" * "\n"
    return s
end
function display_summary_city(out::Dict)
    s = ""
    s *= out[:city] * ": Jan. 2013 - Dec. 2019" * "\n"
    s *= "Population: $(@sprintf("%.2f mil.", (out[:all_pop]/1e6)))" * "\n"
    s *= "Total killed by police: $(@sprintf("%d", out[:all_kill]))" * "\n"
    s *= "Blacks killed by police: $(@sprintf("%d", out[:blk_kill]))" * "\n"
    s *= "Avg. killed/yr. (per mil.): $(@sprintf("%.1f", out[:avg_all_kill_py_pMM]))" * "\n"
    s *= "Avg. Blacks killed/yr. (per mil.): $(@sprintf("%.1f", out[:avg_blk_kill_py_pMM]))" * "\n"
    s *= "Blacks killed rate = $(@sprintf("%.2fx", out[:blk_v_all_kill_py_pMM_x])) all killed rate" * "\n"
    s *= "Black pop. proportion: $(@sprintf("%.1f", 100out[:blk_pop_pct]))%" * "\n"
    s *= "Black killed proportion: $(@sprintf("%.1f", 100out[:pct_blk_victims]))%" * "\n"
    s *= "Avg. resident homicides/yr. (per mil.): $(@sprintf("%.1f", out[:civ_mur_rate_pMM]))" * "\n"
    s *= "Avg. police homicides/yr.(per mil.): $(@sprintf("%.1f", out[:pol_hom_rate_pMM]))" * "\n"
    s *= "Police homicides = $(@sprintf("%.1f", 100out[:all_kill_rate_as_pct_murder_rate]))% of total homicides/yr." * "\n"
    s *= "Police killings per 10k arrests: $(@sprintf("%.1f", out[:kill_p10k_arrests]))" * "\n"
    return s
end

##
## get all output
##

state_strings = Dict()
for k in dfs["2013-2019 Killings by State"].State
    state_strings[k] = display_summary_state(get_summary_state(dfs, k))
end

city_strings = Dict()
for k in dfs["2013-2019 Killings by PD"].City
    city_strings[k] = display_summary_city(get_summary_city(dfs, k))
end

##
## write output
##

open("state_strings.csv", "w") do io
    writedlm(io, hcat(collect(keys(state_strings)), collect(values(state_strings))), ',')
end

open("city_strings.csv", "w") do io
    writedlm(io, hcat(collect(keys(city_strings)), collect(values(city_strings))), ',')
end
