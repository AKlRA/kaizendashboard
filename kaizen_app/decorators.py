from django.shortcuts import redirect
from functools import wraps

def profile_required(profile_type):
    def decorator(view_func):
        @wraps(view_func)
        def _wrapped_view(request, *args, **kwargs):
            active_profile_type = request.session.get('active_profile_type')
            if active_profile_type != profile_type:
                return redirect('login')
            return view_func(request, *args, **kwargs)
        return _wrapped_view
    return decorator