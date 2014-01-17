
extensions1 = +header_attributes+fenced_code_blocks+implicit_figures
extensions2 = +fancy_lists+simple_tables+table_captions
extensions3 = +pandoc_title_block+strikeout+superscript+subscript
extensions4 = +inline_code_attributes+tex_math_dollars
extensions  = $(extensions1)$(extensions2)$(extensions3)$(extensions4)

args  = -f markdown$(extensions) \
	--standalone \
	--self-contained \
	--smart \
	--toc \
	--data-dir media

files = main.txt \
	managing-expectations.txt \
	arranging-funding.txt \
	organizing-meetings.txt

handbook.html: Makefile $(files)
	pandoc $(args) -o handbook.html $(files)
