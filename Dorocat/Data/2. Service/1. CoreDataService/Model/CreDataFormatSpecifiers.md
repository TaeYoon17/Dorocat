#  NSPredicate 포맷 지정자(Format Specifiers) 타입 기호

NSPredicate에서 사용하는 주요 포맷 지정자들은 다음과 같습니다:
기본 타입 지정자

%@ - 객체 참조(Object references)

NSString, NSArray, NSDictionary 등 모든 Objective-C 객체
예: @"name == %@", @"category IN %@"


%d - 정수(Integer)

32비트 부호 있는 정수
예: @"age == %d"


%i - 정수(Integer), %d와 동일
%u - 부호 없는 정수(Unsigned integer)

예: @"count == %u"


%f - 부동소수점 수(Float, Double)

예: @"price == %f"


%ld - 64비트 정수(Long integer)

예: @"fileSize == %ld"


%lu - 64비트 부호 없는 정수(Unsigned long integer)

예: @"maxCount == %lu"


%lld - 64비트 정수(Long long integer)

예: @"bigNumber == %lld"


%llu - 64비트 부호 없는 정수(Unsigned long long integer)

예: @"veryBigNumber == %llu"



불리언 및 특수 타입

%K - 키 경로(Key path)

동적으로 속성 이름을 지정할 때 사용
예: @"%K == %@", @"name", @"John"


%c - 문자(Character)

예: @"initial == %c", 'A'


%b - 불리언(Boolean)

예: @"isActive == %b", YES



다른 유용한 지정자

%% - % 문자 자체를 표현

예: @"code LIKE '%%prefix%%'" (SQL의 LIKE '%prefix%'와 유사)


%g - 더 간결한 부동소수점 표현(일반적으로 %f보다 권장)

예: @"rating == %g", 4.5
