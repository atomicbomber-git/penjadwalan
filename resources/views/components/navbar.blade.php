<nav class="mb-3 navbar navbar-expand-md navbar-light bg-white shadow-sm">
    <div class="container">
        <a class="navbar-brand"
           href="{{ url('/') }}"
        >
            {{ config('app.name', 'Laravel') }}
        </a>
        <button class="navbar-toggler"
                type="button"
                data-toggle="collapse"
                data-target="#navbarSupportedContent"
                aria-controls="navbarSupportedContent"
                aria-expanded="false"
                aria-label="{{ __('Toggle navigation') }}"
        >
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse"
             id="navbarSupportedContent"
        >
            <!-- Left Side Of Navbar -->
            <ul class="navbar-nav mr-auto">
                @guest

                <li class="nav-item">
                    <a class="nav-link @if(\Illuminate\Support\Facades\Route::is("kegiatan-belajar.index")) active @endif"
                       href="{{ route("kegiatan-belajar.index") }}">
                        Kegiatan Belajar
                    </a>
                </li>

                <li class="nav-item">
                    <a class="nav-link @if(\Illuminate\Support\Facades\Route::is("penggunaan-ruangan")) active @endif"
                       href="{{ route("penggunaan-ruangan") }}">
                        Penggunaan Ruangan
                    </a>
                </li>

                @endguest
            </ul>

            <!-- Right Side Of Navbar -->
            <ul class="navbar-nav ml-auto">
                <!-- Authentication Links -->
                @guest
                    <li class="nav-item">
                        <a class="nav-link"
                           href="{{ route('login') }}"
                        >{{ __('Login') }}</a>
                    </li>
                @else
                    <li class="nav-item dropdown">
                        <a id="navbarDropdown"
                           class="nav-link dropdown-toggle"
                           href="#"
                           role="button"
                           data-toggle="dropdown"
                           aria-haspopup="true"
                           aria-expanded="false"
                           v-pre
                        >
                            {{ Auth::user()->name }}
                            <span class="caret"></span>
                        </a>

                        <div class="dropdown-menu dropdown-menu-right"
                             aria-labelledby="navbarDropdown"
                        >
                            <a class="dropdown-item"
                               href="{{ route('logout') }}"
                               onclick="event.preventDefault();
                                                     document.getElementById('logout-form').submit();"
                            >
                                {{ __('Logout') }}
                            </a>

                            <form id="logout-form"
                                  action="{{ route('logout') }}"
                                  method="POST"
                                  style="display: none;"
                            >
                                @csrf
                            </form>
                        </div>
                    </li>
                @endguest
            </ul>
        </div>
    </div>
</nav>
