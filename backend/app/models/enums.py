import enum


class ProjectRole(str, enum.Enum):
    admin = "admin"          # Admin / Project Manager (MVP)
    reviewer = "reviewer"    # Reviewer
    arbiter = "arbiter"      # Third reviewer / conflict arbiter


class ProjectType(str, enum.Enum):
    scientific = "scientific"   # PRISMA path
    technical = "technical"     # GT2 path


class ReviewMode(str, enum.Enum):
    collaborative = "collaborative"
    double = "double"
    mixed = "mixed"


class ProjectStatus(str, enum.Enum):
    planning = "planning"
    in_progress = "in_progress"
    completed = "completed"


class FieldGroup(str, enum.Enum):
    identification = "identification"
    characterization = "characterization"
    analytical = "analytical"
    reviewer_metadata = "reviewer_metadata"


class SubmissionStatus(str, enum.Enum):
    registered = "registered"
    in_review = "in_review"
    completed = "completed"
    archived = "archived"


class DocumentPhase(str, enum.Enum):
    # PRISMA
    identification = "identification"
    screening = "screening"
    eligibility = "eligibility"
    included = "included"
    excluded = "excluded"
    # GT2 (reuses included/excluded, adds intermediate phases)
    gt2_registered = "gt2_registered"
    gt2_coded = "gt2_coded"


class AssignmentMethod(str, enum.Enum):
    manual = "manual"
    random = "random"
    rule = "rule"
    ai = "ai"


class AssignmentRole(str, enum.Enum):
    reviewer1 = "reviewer1"
    reviewer2 = "reviewer2"
    arbiter = "arbiter"


class AssignmentStatus(str, enum.Enum):
    pending = "pending"
    in_progress = "in_progress"
    completed = "completed"


class Decision(str, enum.Enum):
    include = "include"
    exclude = "exclude"
    unsure = "unsure"


class ConflictStatus(str, enum.Enum):
    open = "open"
    escalated = "escalated"
    resolved = "resolved"