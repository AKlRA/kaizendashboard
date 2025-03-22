from django.utils.functional import SimpleLazyObject

class ActiveProfileMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if hasattr(request, 'user') and request.user.is_authenticated:
            request.active_profile = None
            if request.user.profiles.filter(user_type='admin').exists():
                request.active_profile = request.user.profiles.filter(user_type='admin').first()
            else:
                active_type = request.session.get('active_profile_type')
                if active_type:
                    request.active_profile = request.user.profiles.filter(user_type=active_type).first()
        
        return self.get_response(request)