resource "aws_iam_role" "daniel_role_tf" {
  name = "Daniel_tf"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "daniel-tf"
  }
}

resource "aws_iam_instance_profile" "Daniel_profile-tf" {
  name = "Daniel_profile-tf"
  role = aws_iam_role.daniel_role_tf.name
}

resource "aws_iam_role_policy" "Daniel_policy" {
  name = "Daniel-role-tf"
  role = aws_iam_role.daniel_role_tf.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
"sqs:*",
"dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
