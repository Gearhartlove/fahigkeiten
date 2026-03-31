#!/usr/bin/env elixir

{opts, _argv, _invalid} =
  OptionParser.parse(System.argv(),
    strict: [
      rows: :string,
      reviewers: :string,
      title: :string,
      project: :string,
      assignee: :string
    ]
  )

rows_path = Keyword.get(opts, :rows)
reviewers_csv = Keyword.get(opts, :reviewers, "")

if is_nil(rows_path) or rows_path == "" do
  IO.puts(:stderr, "Missing required option: --rows <path-to-tsv>")
  System.halt(1)
end

reviewers =
  reviewers_csv
  |> String.split(",", trim: true)
  |> Enum.map(&String.trim/1)
  |> Enum.reject(&(&1 == ""))

if reviewers == [] do
  IO.puts(:stderr, "Missing reviewers. Use --reviewers \"Chris,Maxwell,Eric,Gia\".")
  System.halt(1)
end

title = Keyword.get(opts, :title, "quick handoff")
project = Keyword.get(opts, :project, "Application Assistant")
assignee = Keyword.get(opts, :assignee, "self")

defmodule Handoff do
  def parse_row(line) do
    case String.split(line, "\t", parts: 8) do
      [id, issue_title, state, linear_url, pr_number, _pr_title, pr_url, description] ->
        %{
          id: id,
          issue_title: issue_title,
          state: state,
          linear_url: linear_url,
          pr_number: pr_number,
          pr_url: pr_url,
          summary: summarize(description, issue_title)
        }

      _ ->
        nil
    end
  end

  def summarize(description, fallback_title) do
    cleaned =
      description
      |> then(&Regex.replace(~r/!\[[^\]]*\]\([^\)]*\)/, &1, " "))
      |> then(&Regex.replace(~r/`[^`]*`/, &1, " "))
      |> String.replace(~r/\s+/, " ")
      |> String.trim()

    base = if cleaned == "", do: fallback_title, else: cleaned

    sentence =
      case Regex.run(~r/^(.{1,180}?[.!?])(?:\s|$)/, base, capture: :all_but_first) do
        [first_sentence] -> first_sentence
        _ -> base
      end

    if String.length(sentence) > 180 do
      String.slice(sentence, 0, 177) <> "..."
    else
      sentence
    end
  end

  def assign(rows, reviewers) do
    Enum.map(rows, fn row ->
      reviewer = reviewers |> Enum.shuffle() |> hd()
      Map.put(row, :reviewer, reviewer)
    end)
  end
end

rows =
  rows_path
  |> File.read!()
  |> String.split("\n", trim: true)
  |> Enum.map(&Handoff.parse_row/1)
  |> Enum.reject(&is_nil/1)

if rows == [] do
  IO.puts(:stderr, "No rows to render. Ensure the TSV contains open PR-backed issues.")
  System.halt(1)
end

assigned_rows = Handoff.assign(rows, reviewers)
groups = Enum.group_by(assigned_rows, & &1.reviewer)
date = Date.utc_today() |> Date.to_iso8601()

header = [
  "Team - #{title} (#{date}).",
  "",
  "I pulled my #{project} issues assigned to #{assignee} with open (unmerged) GitHub PR attachments and randomly assigned first-pass review.",
  "",
  "Randomization method per issue:",
  "`#{inspect(reviewers)} |> Enum.shuffle() |> hd()`",
  ""
]

sections =
  reviewers
  |> Enum.flat_map(fn reviewer ->
    case Map.get(groups, reviewer, []) do
      [] ->
        []

      items ->
        issue_lines =
          Enum.flat_map(items, fn item ->
            [
              "- #{item.id} (#{item.state}) - #{item.summary}",
              "  Linear: #{item.linear_url}",
              "  PR ##{item.pr_number}: #{item.pr_url}"
            ]
          end)

        [reviewer | issue_lines] ++ [""]
    end
  end)

footer = ["Thanks everyone."]

(header ++ sections ++ footer)
|> Enum.join("\n")
|> IO.puts()
