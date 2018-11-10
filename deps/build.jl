using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libwcs"], :libwcs),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaAstro/WCSLIBBuilder/releases/download/v6.2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/WCS.v6.2.0.aarch64-linux-gnu.tar.gz", "531ce2ce382183853013183a99b53dbf5be7a2b15f758a6e7edc220a47be1316"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/WCS.v6.2.0.aarch64-linux-musl.tar.gz", "39114c6290f4d954e6b4c3c5ae3b6597bc314826f3645b1ed92be51e8a1ef694"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/WCS.v6.2.0.arm-linux-gnueabihf.tar.gz", "39a1f821e5aa26a853503eed7ef9a3d565074a1b6aaf8bcf6921770772670379"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/WCS.v6.2.0.arm-linux-musleabihf.tar.gz", "024427267890da67d378754fffb898bdc56dedeb6df3e24a14ef61d231600b23"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/WCS.v6.2.0.i686-linux-gnu.tar.gz", "11f3e82eb0b4532af5fba410ae2ccdf7fda17fd3444c697f7aeb0831bd0bb261"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/WCS.v6.2.0.i686-linux-musl.tar.gz", "96e5f47f65f047d5189105a39c703c82bc50560473e8eea4d41632ccd2d40b56"),
    Windows(:i686) => ("$bin_prefix/WCS.v6.2.0.i686-w64-mingw32.tar.gz", "35bfbb8a323a561c5fc79931a8f102504bb2ebf7187b0de49389ee39d683186a"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/WCS.v6.2.0.powerpc64le-linux-gnu.tar.gz", "92b2063ebcfc5c246ca9cbd5cee49e5dba87c56046313acf6354ee992a3071ff"),
    MacOS(:x86_64) => ("$bin_prefix/WCS.v6.2.0.x86_64-apple-darwin14.tar.gz", "9f2a5e08e64dc812a1bf7f618ee0f08002a2d8761153025fa198e4eebce4be92"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/WCS.v6.2.0.x86_64-linux-gnu.tar.gz", "da475ac6b2d7e99c141bf7489e965816a4ef754b9a2f749bed1d1a003f5d4027"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/WCS.v6.2.0.x86_64-linux-musl.tar.gz", "93f8bf9557758fe943ec8da2b77d629212ea51b4a98f62c14013e81f2b41bec6"),
    FreeBSD(:x86_64) => ("$bin_prefix/WCS.v6.2.0.x86_64-unknown-freebsd11.1.tar.gz", "726d92af7968548026e433bebf5ae32a198229e8462169c207dd2708f1491b8d"),
    Windows(:x86_64) => ("$bin_prefix/WCS.v6.2.0.x86_64-w64-mingw32.tar.gz", "c27daa0c9d99a8c1d73599b4f3c485d9d54a0ec927e237bcccfaf2e3dd231368"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
