from pydantic import BaseModel

class CountryOut(BaseModel):
    id: int
    name: str
    code: str

    class Config:
        from_attributes = True

class LanguageOut(BaseModel):
    id: int
    name: str
    code: str

    class Config:
        from_attributes = True