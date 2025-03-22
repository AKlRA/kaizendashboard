# kaizen_app/api/views.py
from rest_framework import viewsets
from ..models import KaizenSheet
from .serializers import KaizenSheetSerializer

class KaizenSheetViewSet(viewsets.ModelViewSet):
    queryset = KaizenSheet.objects.all()
    serializer_class = KaizenSheetSerializer

    def get_queryset(self):
        user = self.request.user
        if active_profile.is_coordinator:
            return KaizenSheet.objects.all()
        elif active_profile.is_hod:
            return KaizenSheet.objects.filter(
                employee__profile__department=active_profile.department
            )
        return KaizenSheet.objects.filter(employee=user)