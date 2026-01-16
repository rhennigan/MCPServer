VerificationTest[
    1 / 0,
    ComplexInfinity,
    TestID -> "TestFile2-Division@@Tests/Resources/TestFile2.wlt:1,1-5,2"
]

VerificationTest[
    1 / 0,
    ComplexInfinity,
    { Power::infy },
    TestID -> "TestFile2-Division-Error@@Tests/Resources/TestFile2.wlt:7,1-12,2"
]

VerificationTest[
    Pause[ 2 ],
    Null,
    TimeConstraint -> Quantity[ 1, "Seconds" ],
    TestID         -> "TestFile2-Pause@@Tests/Resources/TestFile2.wlt:14,1-19,2"
]

VerificationTest[
    x,
    y,
    SameTest -> Equal,
    TestID   -> "TestFile2-Equal@@Tests/Resources/TestFile2.wlt:21,1-26,2"
]

VerificationTest[
    Print[ "Hello, world!" ],
    Null,
    TestID -> "TestFile2-Print@@Tests/Resources/TestFile2.wlt:28,1-32,2"
]