<!doctype html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1">

    <!-- CSRF Token -->
    <meta name="csrf-token"
          content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'Laravel') }}</title>

    <!-- Fonts -->
    <link rel="dns-prefetch"
          href="//fonts.gstatic.com">
    <link href="https://fonts.googleapis.com/css?family=Nunito"
          rel="stylesheet">

    <!-- Styles -->
    <link href="{{ asset('css/app.css') }}"
          rel="stylesheet">

    @livewireStyles
</head>
<body>
<div id="app">
    @include('components.navbar')
    <div class="container">
        <div class="row">
            @auth
                <aside class="col-sm-12 col-md-2 mb-4 mb-sm-0 ">
                    <nav class="nav flex-column">
                        <div class="my-3">
                            <div class="font-weight-bold text-primary text-uppercase border-bottom">
                                Data
                            </div>

                            <div class="nav-item">
                                <a class="px-0" href="{{ route("kegiatan-belajar.index") }}">
                                    Kegiatan Belajar
                                </a>
                            </div>
                        </div>

                        <div class="my-3">
                            <div class="font-weight-bold text-primary text-uppercase border-bottom">
                                Operasi
                            </div>

                            <div class="nav-item">
                                <a class="px-0" href="{{ route("penggunaan-ruangan") }}">
                                    Penggunaan Ruangan
                                </a>
                            </div>
                        </div>
                    </nav>

                </aside>
            @endauth

            <main class="col-sm-12 @auth col-md-10 @else col-md-12 @endauth ">
                @yield('content')
            </main>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="{{ asset('js/app.js') }}"></script>

@livewireScripts
@stack("scripts")
</body>
</html>
