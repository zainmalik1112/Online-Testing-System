class Instructions{

  String getPracticeTestInstruction()
  {
    String instruction = "The given time in practice test is about 35 min."
        "\n you must attempt the questions in the given time"
        "\n There is no negative marking for now and each question carries 1 mark. There are"
        " total of 15 to 30 questions in each practice test.";
    return instruction;
  }

  String getECATInstruction()
  {
    String instruction = "The following ECAT test is of 100 min. It is advised to give 1 min to"
        " each question. Each question carries 4 marks. There is a negative marking of 1 so answer the "
        "questions carefully. There are total of 100 questions. Distribution is as follows:"
        "\n Physics: 30"
        "\n Mathematics: 30"
        "\n English 10"
        "\n Chemistry/Comp Science 30";

    return instruction;
  }

  String getNETInstruction()
  {
    String instruction = "The following NET test is of 180 min. It is advised to give at least 45 seconds to"
        " each question. Each question carries 1 mark. There is no negative marking so answer all the "
        "questions. There are total of 200 questions. Distribution is as follows:"
        "\n Physics: 60"
        "\n Mathematics: 80"
        "\n English 20"
        "\n Chemistry/Comp Science 30"
        "\n Intelligence 10";

    return instruction;
  }

  String getFASTInstruction()
  {
    String instruction = "The following FAST test is of 100 min. It is advised to give 1 min to"
        " each question. Each question 1 marks. There is a no negative marking for now."
        " There are total of 100 questions. Distribution is as follows:"
        "\n\n For Pre-Engineering:"
        "\n Basic Mathematics 10"
        "\n Physics: 20"
        "\n Mathematics: 40"
        "\n English 10"
        "\n Intelligence 20"
        "\n\nFor ComputerScience:"
        "\n Basic Mathematics: 20"
        "\n Mathematics: 50"
        "\n English: 10"
        "\n Intelligence: 20";
    return instruction;
  }


}